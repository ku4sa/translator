bison -d pr.y
gcc -c pr.tab.c -o pr.tab.o
flex pr.l
gcc -c lex.yy.c -o lex.yy.o
gcc  lex.yy.o  pr.tab.o -o program
program
pause
