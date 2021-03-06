
class mumathParser extends Parser;
options {
   k=2;
}
{
   String mungID(Token tok)
   {
      int i;
      String t = tok.getText();
      String o = "";
      if(t.equals("@")){ o = "last";}
      else if(t.equals("#E")){o = "%E";}
      else if(t.charAt(t.length()-1) == '#')
        { o = "lie_"+t.substring(0,t.length()-1).toLowerCase(); }
      else if((i = t.indexOf('#')) >= 0)
      {
         o = "lie_"+(new StringBuffer(t)).deleteCharAt(i).toString().toLowerCase();
      }
      else o = t.toLowerCase();
      return(o);
   }
   void p(String s){ System.out.print(s); }
   void p(char s){ System.out.print(s); }
}
program : ((functionDefinition|assignment|functionDesignator)
   (SEMI|DOLLAR) { System.out.println('$'); } )* EOF ;

// empty : /* empty */ ;
assignment : (i:ID COLON { p(mungID(i)+':'); } )+ expression ;

list : LPAREN { p('('); }
       (RPAREN { p(')'); }
       |i:ID { p(mungID(i)); }
           (COMMA j:ID{p(','+mungID(j)); } )*
	   RPAREN { p(')'); } ) ;

functionDefinition : FUNCTION i:ID { p(mungID(i)); } list COMMA
   { System.out.println(":=block([last]"); } statments (COMMA)? ENDFUN { p(")"); } ;

actualParameter : expression|assignment ;

statments : (loop|when|block|assignment|expression|functionDesignator)
   (COMMA { System.out.println(','); } statments)* ;

block : BLOCK {p("block(");} statments COMMA ENDBLOCK  {p(')');} ;
loop : LOOP {System.out.println("do(");}
          statments (COMMA)? ENDLOOP { System.out.println(")"); };
when {boolean comma = false; } : WHEN {p("if "); }
        expression {p(" then "); }
        ((COMMA)? EXIT { p("return(last)"); }
	| { p('('); } COMMA statments (COMMA {comma = true;} )?
          EXIT { if(!comma)p(','); p("return(last))"); } ) ;
expression : simpleExpression ( relationalOperator simpleExpression)* ;

relationalOperator
    : equal | NOT_EQUAL {p('#');} | LT  {p('<');} | LE {p("<=");} |
       GE {p(">=");} | GT {p('>');} | EQUATION  {p('=');}
    ;

simpleExpression
    : (MINUS {p('-');} )?
      term ( addingOperator term )*
    ;

addingOperator
    : PLUS  {p('+');} | MINUS  {p('-');} | OR {p(" OR "); }
    ;

term
    : factor ( multiplyingOperator factor )*
    ;

multiplyingOperator
    : STAR{p('*');} | SLASH{p('/');} | MOD {p(" mod ");} | AND {p(" AND ");} |
       POWER {p('^');}
    ;

factor
    : i:ID {p(mungID(i));}
    | constant
    | LPAREN {p('(');} expression RPAREN {p(')');}
    | functionDesignator
    | NOT {p(" NOT ");} factor
    ;

constant
    : n:NUMBER {p(n.getText());}
    | s:STRING {p(s.getText());}
    | QUOTE i:ID {p('\''+mungID(i));}
    | QUOTE qs:STRING {p('\''+qs.getText());}
    ;

functionDesignator
    : i:ID LPAREN { p(mungID(i)+'('); }
       ((actualParameter ( COMMA { p(','); } actualParameter) *)
       |)
       RPAREN { p(')'); } ;

equal : (EQF|EQC) { p('='); };

class mumathLexer extends Lexer;

options {
   k=2;
   charVocabulary = '\3'..'\377';
}

tokens {
   BLOCK = "BLOCK" ;
   ENDBLOCK = "ENDBLOCK" ;
   FUNCTION = "FUNCTION" ;
   ENDFUN = "ENDFUN" ;
   EQF = "EQ" ;
   LOOP = "LOOP" ;
   ENDLOOP = "ENDLOOP" ;
   WHEN = "WHEN" ;
   EXIT = "EXIT" ;
   OR = "OR" ;
}

WS : (' ' | '\t' | '\n' {newline();} | '\r') { _ttype = Token.SKIP; } ;
COMMENT : '%' ('\n' {newline();} | ~('%'|'\n'))* '%'
   { System.out.println("/* "+ getText() +" */"); $setType(Token.SKIP);};


EQUATION	: "=="	;
QUOTE		: '\''	;
PLUS		: '+'	;
MINUS		: '-'	;
STAR		: '*'	;
SLASH		: '/'	;
COMMA		: ','	;
SEMI		: ';'	;
DOLLAR		: '$'	;
COLON		: ':'	;
EQC		: '='	;
NOT_EQUAL	: "<>"	;
LT		: '<'	;
LE		: "<="	;
GE		: ">="	;
GT		: '>'	;
LPAREN		: '('	;
RPAREN		: ')'	;
POWER		: '^'	;

ID options {testLiterals=true;} :
  ('A'..'Z' | '@' | '{' | '#') ('A'..'Z'|'0'..'9'|'#'|'}')* (ARR)? ;
ARR: '[' NUMBER ']' ;
STRING : '"' (~'"')* '"';
NUMBER : ('0'..'9')+;
