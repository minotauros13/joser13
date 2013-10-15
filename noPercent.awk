#!/usr/bin/awk -f
{
	text = text $0
	if ( $0 !~ /.*%$/ ) {
		print text
		text = ""
	} else
		text = substr( text, 1, length( text ) - 1 )
}
