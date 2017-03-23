default:
	echo "no default"

data/address_names.tsv:
	head -n 30960 ../addressbase-data/stats/address/name.tsv \
	| csvcut -tc 1 \
	| awk 'NF' \
	| grep -vE '^[0-9]+$$' \
	| csvgrep -tc 1 -l -r '.' \
	| csvformat -T \
	| sed 's/line_number/id/' \
	> $@

data/town-administrative-area-count.tsv:
	mix compile >&2
	mix run -e 'UniqueAndCount.unique_town_admin_from_dir("../addressbase-data/cache/street/")' \
	| nl -n ln -v 0 \
	| sed -E 's/^([0-9]+)[ ]+/\1/' \
	| sed -E 's/^0/town-id/' \
	> $@
