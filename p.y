%{
    #include <stdio.h>
    #include <string.h>
    #include "defs.h"

    int level = 0;
    int pos = 0;
    const int INDENT_LENGTH = 4; 
    const int LINE_WIDTH = 78;

    void indent(int poziom);
%}

%union{
    char s[MAXSTRLEN + 1];
}

%token<s> PI_TAG_BEG PI_TAG_END STAG_BEG ETAG_BEG TAG_END ETAG_END CHAR S

%type<s> pusty_znacznik para_znacznikow start_tag end_tag word

%%

wejscie:
    wstep znaki_biale_i_nowego_wiersza element znaki_biale_i_nowego_wiersza
    ;

wstep:
    wstep pi znaki_nowego_wiersza
    | znaki_nowego_wiersza
    | pi znaki_nowego_wiersza
    ;

znaki_nowego_wiersza:
    znaki_nowego_wiersza '\n'
    | %empty
    ;

znaki_biale_i_nowego_wiersza:
    znaki_biale_i_nowego_wiersza '\n'
    | znaki_biale_i_nowego_wiersza S
    | %empty
    ;

pi:
    PI_TAG_BEG PI_TAG_END { printf("<? \"%s\" ?>\n", $1); }
    ;

element:
    pusty_znacznik { indent(level); printf("< \"%s\" />\n", $1); }
    | para_znacznikow
    ;

pusty_znacznik:
    STAG_BEG ETAG_END
    ;

para_znacznikow:
    start_tag zawartosc end_tag  { if (strcmp($1, $3) != 0) { indent(level); printf("ERROR: Niezgodność znaczników: \"%s\" i \"%s\"\n", $1, $3); } }
    ;

start_tag:
    STAG_BEG TAG_END { indent(level); printf("< \"%s\" >\n", $1); level++; }
    ;

end_tag:
    ETAG_BEG TAG_END { level--; indent(level); printf("</ \"%s\" >\n", $1); }
    ;

zawartosc:
    zawartosc element
    | zawartosc S 
    | zawartosc word
    | zawartosc '\n'
    | %empty

word:
    CHAR
    ;

%%

int main() {
    yyparse();
    return 0;
}

void yyerror(const char *txt)
{
	printf("Syntax error %s\n", txt);
    return 0;
}

void indent(int poziom) { 
    for (int i = 0; i < poziom; i++) {
        for (int j = 0; j < INDENT_LENGTH; j++) {
            printf(" ");
        }
    }
}
