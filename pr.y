%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include<ctype.h>

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;
    extern FILE *yyout;

    char* findvar(char* b)
    {
        static char buf[64];
        int i = 0;
        for (i = 0; i < 32; ++i)
        {
            if (b[i] != '=')
                buf[i] = b[i];
            else
            {
                buf[i] = '\0';
                return buf;
            }
        }
    }

    void yyerror (char *s) 
    {
        fprintf (stdout, "%s\n", s);
    }


    typedef struct
    {
        char str[1024];
        int number;
    } YYSTYPE;
    #define YYSTYPE YYSTYPE

    char gbuf[64];
%}

%token PROGRAM END_PROGRAM
%token ID NUMBER VAR END_VAR INT 
%token WHILE END_WHILE REPEAT UNTIL END_REPEAT FOR END_FOR DO TO BY
%token IF THEN ELSE  END_IF
%token ASSIGN NOT_EQ MORE_OR_EQ LESS_OR_EQ
%token mod AND OR

%type<str> ID NUMBER  start operations operation destination declarations declaration priority4 priority3 priority2 priority1 priority0
%start start

%%

start: PROGRAM operations END_PROGRAM                                        { fprintf(yyout, "#include <stdio.h>\n#include <stdlib.h>\n\nint main(){\n%s \n", $2); };

operations:                                                                 	{  } 
|       operation                                                           	{ strcpy($$, $1); }
|       operations operation                                                	{ strcpy($$,$1); strcat($$,$2); }
;

operation:  destination { strcpy($$, $1); }
|       priority3 ';'               
			{ strcpy($$, $1); strcat($$, ";\n"); }
|       IF priority4 THEN operations ELSE operations END_IF ';'  				
			{ strcpy($$, "if"); strcat($$, $2); strcat($$, "\n{\n\t"); strcat($$, $4); strcat($$, "} \nelse \n{\n\t"); strcat($$, $6); strcat($$, "\n}\n"); }
|       IF priority4 THEN operation END_IF ';'                     			
			{ strcpy($$, "if "); strcat($$, $2); strcat($$, "{\n"); strcat($$, $4); strcat($$, "}\n"); }
|       FOR destination TO priority4 BY priority4 DO operations END_FOR ';'  	
			{ strcpy(gbuf,findvar($2)); strcpy($$, "for ("); strcat($$, $2); strcat($$, "; "); strcat($$, gbuf); strcat($$, " < "); strcat($$, $4); strcat($$, "; "); strcat($$, gbuf); strcat($$, "="); strcat($$, gbuf); if(atoi($6) > 0) {strcat($$, "+");} strcat($$, $6); strcat($$, ") \n{\n\t"); strcat($$, $8); strcat($$, "\n}\n"); }
|       REPEAT operations UNTIL priority4 ';' END_REPEAT ';'          
			{  strcpy($$, "do {\n");  strcat($$, $2); strcat($$, "} while ("); strcat($$, $4); strcat($$, ");\n"); }
|       WHILE priority4 DO operations END_WHILE ';'                       
			{ strcpy($$, "while "); strcat($$, $2); strcat($$, "  {\n"); strcat($$, $4); strcat($$, "}\n");}
|       VAR declarations END_VAR  { strcpy($$, $2); }
;
declarations:                                                               { }
|       declaration                                                         { strcpy($$, $1); }
|       declarations declaration                                            { strcpy($$,$1); strcat($$,$2); }
;

declaration: ID ':' INT ';'                                                { strcpy($$, "int "); strcat($$, $1); strcat($$, " = 0;\n"); }
;

destination: ID ASSIGN priority3                                   		{ strcpy($$, $1); strcat($$, "="); strcat($$, $3); }
;

priority4:   priority3
|       priority4 AND priority3													{ strcpy($$, $1); strcat($$, "&&"); strcat($$, $3 ); }
|		priority4 OR priority3													{  strcpy($$, $1); strcat($$, "||");strcat($$, $3 ); }


priority3:   priority2 
|       priority3 '=' priority2                                            		{  strcpy($$, $1); strcat($$, "=="); strcat($$, $3); }
|       priority3 NOT_EQ priority2                                       		{  strcpy($$,$1); strcat($$, "!="); strcat($$, $3); }
| 		priority3 '<' priority2   												{ strcpy($$,$1); strcat($$, "<"); strcat($$, $3); }
| 		priority3 '>' priority2   												{ strcpy($$,$1); strcat($$, ">"); strcat($$, $3); }
| 		priority3 MORE_OR_EQ priority2   										{ strcpy($$,$1); strcat($$, ">="); strcat($$, $3); }
| 		priority3 LESS_OR_EQ priority2  										{ strcpy($$,$1); strcat($$, "<="); strcat($$, $3); }
;

priority2:   priority1                                                          
|       priority2 '+' priority1                                                 { strcpy($$,$1); strcat($$, "+"); strcat($$, $3); }
|       priority2 '-' priority1                                                 { strcpy($$,$1); strcat($$, "-"); strcat($$, $3); }
|       destination                                                          	{  strcpy($$, $1); }
;

priority1:   priority0                                 
|       priority1 '*' priority0                                                      { strcat($$, "*"); strcat($$, $3); }
|       priority1 '/' priority0                                                      { strcat($$, "/"); strcat($$, $3); }
|       priority1 mod priority0                                                      { strcat($$, " mod "); strcat($$, $3); }
;

priority0:  NUMBER                                                              { strcpy($$,$1); }
|       '-' priority0                                                           { strcpy($$,"-"); strcat($$, $2); }
|	    '(' priority4 ')'                                                  	 	{ strcpy($$, "( "); strcat($$, $2); strcat($$, " )");}
|	    '(' priority2 ')'                                                  		{  strcpy($$, $2);}
|	    '(' priority1 ')'                                                  	  	{  strcpy($$, $2);}
|	    '(' priority3 ')'                                                   	{ strcpy($$, "( "); strcat($$, $2); strcat($$, " )");}
|       ID                                                                 	 { strcpy($$, $1); }
;

%%
int main() { 

    yyin = fopen("source.txt","r");
    yyout = fopen("result.txt","w");
    yyparse();
	fprintf(yyout, "return 0; \n}");	
    fclose(yyin);
    fclose(yyout);  
}