%{
    #include <stdio.h>
    #include <string.h>
    #include "defs.h"

    int level = 0;
    int pos = 0;  // do budowania slowa
    int line_pos = 0; // do ograniczonej dlugosci wiersza
    
    const int INDENT_LENGTH = 4; 
    const int LINE_WIDTH = 78;

    void indent(int poziom);
    void print_word(char *txt);
    void ensure_newline();
    int yyerror(const char *txt);
    int yylex();
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
    PI_TAG_BEG PI_TAG_END { ensure_newline(); indent(level); printf("<? \"%s\" ?>\n", $1); line_pos = 0; }
    ;

element:
    pusty_znacznik { ensure_newline(); indent(level); printf("< \"%s\" />\n", $1); line_pos = 0; }
    | para_znacznikow
    ;

pusty_znacznik:
    STAG_BEG ETAG_END
    ;

para_znacznikow:
    start_tag zawartosc end_tag  { if (strcmp($1, $3) != 0) { ensure_newline(); indent(level); printf("ERROR: Niezgodność znaczników: \"%s\" i \"%s\"\n", $1, $3); line_pos = 0; } }
    ;

start_tag:
    STAG_BEG TAG_END { ensure_newline(); indent(level); printf("< \"%s\" >\n", $1); level++; line_pos = 0; }
    ;

end_tag:
    ETAG_BEG TAG_END { level--; ensure_newline(); indent(level); printf("</ \"%s\" >\n", $1); line_pos = 0; }
    ;

zawartosc:
    zawartosc element
    | zawartosc S 
    | zawartosc word { print_word($2); }
    | zawartosc '\n'
    | %empty

word:
    word CHAR { strcpy($$, $1); $$[pos] = *$2; pos++; $$[pos] = '\0'; }
    | CHAR { *$$ = *$1; $$[1] = '\0'; pos = 1; }
    ;

%%

int main() {
    yyparse();
    return 0;
}

int yyerror(const char *txt)
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

void print_word(char *txt) {
    int len = strlen(txt);
    int indent_size = level * INDENT_LENGTH;

    if (line_pos == 0) {
        indent(level);
        line_pos = indent_size;
    }

    int space_needed = (line_pos == indent_size) ? 0 : 1;
    
    if (line_pos + space_needed + len > LINE_WIDTH) {
        printf("\n");
        indent(level);
        printf("%s", txt);
        line_pos = indent_size + len;
    } else {
        if (space_needed) {
            printf(" ");
        }
        printf("%s", txt);
        line_pos += space_needed + len;
    }
}

void ensure_newline() {
    if (line_pos > 0) {
        printf("\n");
        line_pos = 0;
    }
}
