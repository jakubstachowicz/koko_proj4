%{
    #include <stdio.h>
    #include <string.h>
    #include "defs.h"
    #include "p.tab.h"
    
    int yyerror(const char *txt);
%}

%x ST_COMMENT
%x ST_PI
%x ST_TAG

IDENT ([a-zA-Z]|:|_)[a-zA-Z0-9":""_"\-]*

%%

<INITIAL>"<!--" { BEGIN(ST_COMMENT); }
<ST_COMMENT>"-->" { BEGIN(INITIAL); }
<ST_COMMENT><<EOF>> { return yyerror("Niedomkniety komentarz"); }
<ST_COMMENT>. 

<INITIAL>"<?"{IDENT} { BEGIN(ST_PI); strncpy(yylval.s, yytext + 2, MAXSTRLEN); return PI_TAG_BEG; }
<ST_PI>"?>" { BEGIN(INITIAL); return PI_TAG_END; }
<ST_PI>.

<INITIAL>"<"{IDENT} { BEGIN(ST_TAG); strncpy(yylval.s, yytext + 1, MAXSTRLEN); return STAG_BEG; }
<INITIAL>"</"{IDENT} { BEGIN(ST_TAG); strncpy(yylval.s, yytext + 2, MAXSTRLEN); return ETAG_BEG; }
<ST_TAG>">" { BEGIN(INITIAL); return TAG_END; }
<ST_TAG>"/>" { BEGIN(INITIAL); return ETAG_END; }
<ST_TAG>.

"&lt;" { yylval.s[0] = '<'; return CHAR; }
"&gt;" { yylval.s[0] = '>'; return CHAR; }
"&amp;" { yylval.s[0] = '&'; return CHAR; }
"&apos;" { yylval.s[0] = '\''; return CHAR; }
"&quote;" { yylval.s[0] = '\"'; return CHAR; } 

^[ \t]+
\n { return '\n'; }
\r 
[ \t] { yylval.s[0] = *yytext; return S; }
. { yylval.s[0] = *yytext; return CHAR; }

%%
int yywrap() {
    return 1;
}
 