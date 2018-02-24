/* JFlex example: partial Java language lexer specification */
import java_cup.runtime.*;

/**
 * This class is a simple example lexer.
 */
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

%state STRING

%%

/* KEYWORDS */

/* data types */
<YYINITIAL> "int"              { return symbol(sym.INTEGER); }
<YYINITIAL> "rat"              { return symbol(sym.RATIONAL); }
<YYINITIAL> "float"              { return symbol(sym.FLOAT); }
<YYINITIAL> "dict"              { return symbol(sym.DICTIONARY); }
<YYINITIAL> "seq"              { return symbol(sym.SEQUENCE); }
<YYINITIAL> "set"              { return symbol(sym.SET); }
<YYINITIAL> "bool"            { return symbol(sym.BOOLEAN); }
<YYINITIAL> "top"              { return symbol(sym.TOP); }

/* top-level keywords */
<YYINITIAL> "alias"           { return symbol(sym.ALIAS); }
<YYINITIAL> "thread"           { return symbol(sym.THREAD); }
<YYINITIAL> "fdef"              { return symbol(sym.FUN_DEF); }
<YYINITIAL> "function"              { return symbol(sym.FUNCTION); }
<YYINITIAL> "tdef"              { return symbol(sym.TYPE_DEF); }
<YYINITIAL> "return"              { return symbol(sym.RETURN); }

/* conditional keywords */
<YYINITIAL> "if"           { return symbol(sym.IF); }
<YYINITIAL> "elif"              { return symbol(sym.ELIF); }
<YYINITIAL> "else"              { return symbol(sym.ELSE); }

/* loops keywords */
<YYINITIAL> "while"              { return symbol(sym.WHILE); }
<YYINITIAL> "forall"              { return symbol(sym.FORALL); }
<YYINITIAL> "break"              { return symbol(sym.BREAK); }

/* built-in functions */
<YYINITIAL> "main"              { return symbol(sym.MAIN); }
<YYINITIAL> "print"           { return symbol(sym.PRINT); }
<YYINITIAL> "read"           { return symbol(sym.READ); }

/* boolean types */
<YYINITIAL> "T"              { return symbol(sym.TRUE); }
<YYINITIAL> "F"              { return symbol(sym.FALSE); }

/* END KEYWORDS */

<YYINITIAL> {
  /* identifiers */
  {Identifier}                   { return symbol(sym.IDENTIFIER); }

  /* literals */
  {DecIntegerLiteral}            { return symbol(sym.INTEGER_LITERAL); }
  \"                             { string.setLength(0); yybegin(STRING); }

  /* math operators */
  "+"                            { return symbol(sym.PLUS); }
  "-"                           { return symbol(sym.MINUS); }
  "*"                            { return symbol(sym.MULTIPLICATION); }
  "/"                            { return symbol(sym.DIVISION); }
  "^"                           { return symbol(sym.POWER); }

  /* bool operators */
  "!"                            { return symbol(sym.NOT); }
  "&&"                            { return symbol(sym.AND); }
  "||"                           { return symbol(sym.OR); }

  /* comparison operators */
  "<"                            { return symbol(sym.SMALLER); }
  "<="                            { return symbol(sym.SMALLER_EQ); }
  ">"                           { return symbol(sym.BIGGER); }
  ">="                            { return symbol(sym.BIGGER_EQ); }
  "=="                            { return symbol(sym.EQUAL); }
  "!="                           { return symbol(sym.NOT_EQ); }


  /* comments */
  {Comment}                      { /* ignore */ }

  /* whitespace */
  {WhiteSpace}                   { /* ignore */ }
}

<STRING> {
  \"                             { yybegin(YYINITIAL);
                                   return symbol(sym.STRING_LITERAL,
                                   string.toString()); }
  [^\n\r\"\\]+                   { string.append( yytext() ); }
  \\t                            { string.append('\t'); }
  \\n                            { string.append('\n'); }

  \\r                            { string.append('\r'); }
  \\\"                           { string.append('\"'); }
  \\                             { string.append('\\'); }
}

/* error fallback */
[^]                              { throw new Error("Illegal character <"+yytext()+">"); }