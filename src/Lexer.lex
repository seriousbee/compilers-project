import java_cup.runtime.*;

%%

%class Lexer
%unicode
%cup
%line
%column

%{
  StringBuffer string = new StringBuffer();

  private Symbol symbol(int type) {
    return new Symbol(type, yyline, yycolumn);
  }
  private Symbol symbol(int type, Object value) {
    return new Symbol(type, yyline, yycolumn, value);
  }
%}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment}

// Comment can be the last line of the file, without line terminator.
EndOfLineComment     = "#" {InputCharacter}* {LineTerminator}?
TraditionalComment   = "/#" [^#] ~"#/" | "/#" "#"+ "/"

Identifier = [:jletter:] ([:jletter:] | [:jletterdigit:] | [_])*

DecIntegerLiteral = 0 | [-]?[1-9]([0-9] | [_])*

DecPositiveIntegerLiteral = 0 | [1-9]([0-9] | [_])*

RationalLiteral = {DecIntegerLiteral} [/] {DecPositiveIntegerLiteral}

FloatLiteral = {DecIntegerLiteral} [.] {DecPositiveIntegerLiteral}

CharLiteral = [']([!-9]|[a-z]|[A-Z])[']

%state STRING

%%
<YYINITIAL> {
/* KEYWORDS */

/* data types */
 "int"              { return symbol(sym.INTEGER); }
 "rat"              { return symbol(sym.RATIONAL); }
 "float"              { return symbol(sym.FLOAT); }
 "dict"              { return symbol(sym.DICTIONARY); }
 "seq"              { return symbol(sym.SEQUENCE); }
 "set"              { return symbol(sym.SET); }
 "bool"            { return symbol(sym.BOOLEAN); }
 "top"              { return symbol(sym.TOP); }

/* top-level keywords */
 "alias"           { return symbol(sym.ALIAS); }
 "thread"           { return symbol(sym.THREAD); }
 "fdef"              { return symbol(sym.FUN_DEF); }
 "function"              { return symbol(sym.FUNCTION); }
 "tdef"              { return symbol(sym.TYPE_DEF); }
 "return"              { return symbol(sym.RETURN); }

/* conditional keywords */
 "if"           { return symbol(sym.IF); }
 "elif"              { return symbol(sym.ELIF); }
 "else"              { return symbol(sym.ELSE); }
 "fi"           { return symbol(sym.FI); }
 "then"              { return symbol(sym.THEN); }


/* loops keywords */
 "while"              { return symbol(sym.WHILE); }
 "forall"              { return symbol(sym.FORALL); }
 "break"              { return symbol(sym.BREAK); }
 "do"              { return symbol(sym.DO); }
 "od"              { return symbol(sym.OD); }


/* built-in functions */
 "main"              { return symbol(sym.MAIN); }
 "print"           { return symbol(sym.PRINT); }
 "read"           { return symbol(sym.READ); }


/* boolean types */
 "T"              { return symbol(sym.TRUE); }
 "F"              { return symbol(sym.FALSE); }

/* END KEYWORDS */


  /* identifiers */
  {Identifier}                   { return symbol(sym.IDENTIFIER); }

  /* literals */
  {DecIntegerLiteral}            { return symbol(sym.INTEGER_LITERAL); }
  {RationalLiteral}            { return symbol(sym.RATIONAL_LITERAL); }
  {FloatLiteral}            { return symbol(sym.FLOAT_LITERAL); }

  \"                             { string.setLength(0); yybegin(STRING); }

  /* math operators */
  "+"                            { return symbol(sym.PLUS); }
  "-"                           { return symbol(sym.MINUS); }
  "*"                            { return symbol(sym.MULTI); }
  "/"                            { return symbol(sym.DIVISION); }
  "^"                           { return symbol(sym.POWER); }

  /* bool operators */
  "!"                            { return symbol(sym.NOT); }
  "&&"                            { return symbol(sym.AND); }
  "||"                           { return symbol(sym.OR); }

  /* comparison operators */
  "<="                            { return symbol(sym.SMALLER_EQ); }
  ">="                            { return symbol(sym.BIGGER_EQ); }
  "=="                            { return symbol(sym.EQUAL); }
  "!="                           { return symbol(sym.NOT_EQ); }

  /* set operators */
  "|"                            { return symbol(sym.SET_UNION); }
  "&"                            { return symbol(sym.SET_INTSECT); }
  "\""                           { return symbol(sym.SET_DIFF); }
  "in"                             { return symbol(sym.IN_SET); }

  ":="                             { return symbol(sym.ASSIGNMENT); }
  "("                             { return symbol(sym.L_SOFT_PAREN); }
  ")"                             { return symbol(sym.R_SOFT_PAREN); }
  "<"                            { return symbol(sym.L_TRI_PAREN); }
  ">"                           { return symbol(sym.R_TRI_PAREN); }
  "["                            { return symbol(sym.L_SQ_PAREN); }
  "]"                           { return symbol(sym.R_SQ_PAREN); }
  "{"                            { return symbol(sym.L_CURL_PAREN); }
  "}"                           { return symbol(sym.R_CURL_PAREN); }

  /* seq operators */
  "::"                            { return symbol(sym.SEQ_CONCAT); }
  "len"                             { return symbol(sym.SEQ_LEN); }

  /* comments */
  {Comment}                      { /* ignore */ }

  /* whitespace */
  {WhiteSpace}                   { /* ignore */ }
}

<STRING> {
  \"                             { yybegin(YYINITIAL); return symbol(sym.STRING_LITERAL, string.toString()); }
  [^\n\r\"\\]+                   { string.append( yytext() ); }
  \\t                            { string.append('\t'); }
  \\n                            { string.append('\n'); }

  \\r                            { string.append('\r'); }
  \\\"                           { string.append('\"'); }
  \\                             { string.append('\\'); }
}

<CHAR> {
  \'                             { yybegin(YYINITIAL); return symbol(sym.CHAR_LITERAL, string.toString()); }
  [^\n\r\"\\]+                   { string.append( yytext() ); }
  \\t                            { string.append('\t'); }
  \\n                            { string.append('\n'); }

  \\r                            { string.append('\r'); }
  \\\"                           { string.append('\"'); }
  \\                             { string.append('\\'); }

}

/* error fallback */
[^]                              { throw new Error("Illegal character <"+yytext()+">"); }