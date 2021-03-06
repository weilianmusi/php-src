#!/usr/bin/awk -f
#
# Description: a script that generates a single byte code set to Unicode
# mapping table.
#

function conv(str) {
	if (!match(str, "^0[xX]")) {
		return 0 + str
	}

	retval = 0

	for (i = 3; i <= length(str); i++) {
		n = index("0123456789abcdefABCDEF", substr(str, i, 1)) - 1

		if (n < 0) {
			return 0 + str;
		} else if (n >= 16) {
			n -= 6;
		}

		retval = retval * 16 + n
	}

	return retval
}

BEGIN {
	FS="[ \t#]"
}

/^#/ {
	# Do nothing
}

{
	tbl[conv($1)] = conv($2)
}

END {
	print "/* This file is automatically generated. Do not edit! */"
	if (IFNDEF_NAME) {
		print "#ifndef " IFNDEF_NAME
	}

	print "static const int " TABLE_NAME "[] = {"
	i = 160;
	for (;;) {
		printf("\t0x%04x, 0x%04x, 0x%04x, 0x%04x, 0x%04x, 0x%04x, 0x%04x, 0x%04x", tbl[i++], tbl[i++], tbl[i++], tbl[i++], tbl[i++], tbl[i++], tbl[i++], tbl[i++]);
		if (i != 256) {
			printf(",\n");
		} else {
			print ""
			break;
		}
	}
	print "};"

	if (IFNDEF_NAME) {
		print "#endif /* " IFNDEF_NAME " */"
	}
}
