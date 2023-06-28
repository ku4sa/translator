%{

   typedef struct
   {
      char data[1024];
   } string;

   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>

   #define YYSTYPE string
   void yyerror(char *s);
   #include "pr.tab.h"
%}

%option yylineno

%%

"PROGRAM"          {    return PROGRAM; }
"END_PROGRAM"      {    return END_PROGRAM; }

"VAR"              {    return VAR;}
"INT"              {    return INT; }
"END_VAR"          {    return END_VAR;}

"WHILE"            {    return WHILE; }
"END_WHILE"        {    return END_WHILE; }

"REPEAT"           {    return REPEAT;  }
"UNTIL"            {    return UNTIL; }
"END_REPEAT"       {    return END_REPEAT;  }

"FOR"              {    return FOR;     }
"TO"               {    return TO; }
"DO"               {    return DO; }
"BY"               {    return BY; }
"END_FOR"          {    return END_FOR; }

"IF"               {    return IF; }
"THEN"             {    return THEN; }
"ELSE"             {    return ELSE; }
"END_IF"           {    return END_IF;  }


":="               {    return ASSIGN; }
"<>"               {    return NOT_EQ; }
">="               {    return MORE_OR_EQ; }
"<="               {    return LESS_OR_EQ; }

"mod"			   {	return mod;} 

"AND"              {    return AND;}
"OR"			   {    return OR;}




[0-9]+ {
   strcpy(yylval.data, yytext);
   return NUMBER;
}

[A-z]([A-z]|[0-9])* { 
   strcpy(yylval.data, yytext); 
   return ID;
}

[ \t\n]  

[- + ; ( ) * / = < > :] {  
   return *yytext;  
}
%%

int yywrap()
{
   return 1;
}