#!/bin/sh

PATH_DIR="/path/to/dir"
input="${1:-$PATH_DIR/bookmarks.txt}"
output="${2:-$PATH_DIR/startpage.html}"

HASH_FILE="$input.sha256"

if [ -f "$HASH_FILE" ]; then
    if [ "$(sha256sum $input | awk '{print $1}')" = "$(cat "$HASH_FILE")" ]; then
        exit 0
    fi
else
    sha256sum "$input" | awk '{print $1}' > "$HASH_FILE"
fi

[ -f "$input" ] || {
    echo "error: file not found: $input" >&2
    exit 1
}

escape()
{
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'
}

{
cat <<'EOF'
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Bookmarks</title>

    <style>
        :root {
            color-scheme: dark;
            --bg: #111;
            --surface: #191919;
            --text: #ddd;
            --muted: #777;
            --hover: #252525;
            --accent: #fff;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            background-image: url(''); /* ChangeWallpaper */
	    background-size: cover;
	    background-position: center;
	    background-repeat: no-repeat;
            color: var(--text);
            font-family:
                system-ui,
                -apple-system,
                BlinkMacSystemFont,
                "Segoe UI",
                sans-serif;
        }

        main {
            width: min(700px, calc(100% - 32px));
            margin: 10vh auto;
        }

        header {
            margin-bottom: 2rem;
        }

        h1 {
            margin: 0 0 .4rem;
            color: var(--accent);
            font-size: 1.8rem;
            font-weight: 600;
        }

        header p {
            margin: 0;
            color: var(--muted);
            font-size: .9rem;
        }

        form {
            margin-bottom: 3rem;
        }

        input[type="search"] {
            width: 100%;
            padding: .85rem 1rem;
            border: 1px solid #292929;
            border-radius: 5px;
            outline: none;
            background: var(--surface);
            color: var(--text);
            font: inherit;
        }

        input[type="search"]::placeholder {
            color: var(--muted);
        }

        input[type="search"]:focus {
            border-color: #444;
        }

        section {
            margin-bottom: 2rem;
        }

        h2 {
            margin: 0 0 .6rem;
            color: var(--accent);
            font-size: .7rem;
            font-weight: 600;
            letter-spacing: .12em;
            text-transform: uppercase;
        }

        ul {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 6px;
            padding: 0;
            margin: 0;
            list-style: none;
        }

        a {
            display: block;
            padding: .8rem 1rem;
            border-radius: 5px;
            background: var(--surface);
            color: var(--text);
            text-decoration: none;
            transition: background .1s ease, color .1s ease;
        }

        a:hover,
        a:focus-visible {
            background: var(--hover);
            color: var(--accent);
        }

	details summary {
            display: block;
            padding: .8rem 1rem;
            border-radius: 5px;
            background: var(--surface);
            color: var(--text);
            text-decoration: none;
            transition: background .1s ease, color .1s ease;
	    display: list-item;
	    list-style-type: "+ " !important
        }

        details:hover,
        details:focus-visible {
            background: var(--hover);
            color: var(--accent);
        }

        summary:hover,
        summary:focus-visible {
            background: var(--hover);
            color: var(--accent);
        }

        @media (max-width: 500px) {
            main {
                margin-top: 6vh;
            }

            ul {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
    <main>
        <header>
            <h1>Bookmarks</h1>
        </header>

        <!-- Search -->
        <form action="https://searx.viktoracoric.xyz/search" method="get">
            <input
                type="search"
                name="q"
                placeholder="Search..."
                autocomplete="off"
                autofocus
            >
        </form>
EOF

category=
group=

while IFS=';' read -r path title url || [ -n "$path" ]; do
    [ -z "$path" ] && continue
    case "$path" in \#*) continue ;; esac

    new_category=${path%%/*}

    if [ "$path" = "$new_category" ]; then
        new_group=
    else
        new_group=${path#*/}
    fi

    if [ "$new_category" != "$category" ]; then
        if [ -n "$group" ]; then
            printf '\t\t\t\t</ul>\n'
            printf '\t\t\t</details>\n'
            printf '\t\t</li>\n'
        fi

        if [ -n "$category" ]; then
            printf '            </ul>\n'
            printf '        </section>\n'
        fi

        printf '\n        <section>\n'
        printf '            <h2>%s</h2>\n' \
            "$(printf '%s' "$new_category" | escape)"
        printf '            <ul>\n'

        category=$new_category
        group=
    fi

    if [ "$new_group" != "$group" ]; then
        if [ -n "$group" ]; then
            printf '\t\t\t\t</ul>\n'
            printf '\t\t\t</details>\n'
            printf '\t\t</li>\n'
        fi

        if [ -n "$new_group" ]; then
            printf '\t\t<li>\n'
            printf '\t\t\t<details>\n'
            printf '\t\t\t\t<summary>%s</summary>\n' \
                "$(printf '%s' "$new_group" | escape)"
            printf '\t\t\t\t<ul>\n'
        fi

        group=$new_group
    fi

    title=$(printf '%s' "$title" | escape)
    url=$(printf '%s' "$url" | escape)

    if [ -n "$group" ]; then
        printf '\t\t\t\t\t<li><a href="%s">%s</a></li>\n' \
            "$url" "$title"
    else
        printf '                <li><a href="%s">%s</a></li>\n' \
            "$url" "$title"
    fi

done < "$input"

if [ -n "$group" ]; then
    printf '\t\t\t\t</ul>\n'
    printf '\t\t\t</details>\n'
    printf '\t\t</li>\n'
fi

if [ -n "$category" ]; then
    printf '            </ul>\n'
    printf '        </section>\n'
fi

cat <<'EOF'
    </main>
</body>
</html>
EOF
} > "$output"
