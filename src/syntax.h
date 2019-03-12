/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_HOME_TERAE_DOCUMENTS_INSA_4A_IR_2EME_SEMESTRE_AUTOMATES_ET_LANGAGE_COMPILER_CMAKE_BUILD_DEBUG_SRC_SYNTAX_H_INCLUDED
# define YY_YY_HOME_TERAE_DOCUMENTS_INSA_4A_IR_2EME_SEMESTRE_AUTOMATES_ET_LANGAGE_COMPILER_CMAKE_BUILD_DEBUG_SRC_SYNTAX_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    tMAIN = 258,
    tPRINTF = 259,
    tCONST = 260,
    tINT = 261,
    tVOID = 262,
    tCHAR = 263,
    tENUM = 264,
    tIF = 265,
    tELSE = 266,
    tSWITCH = 267,
    tCASE = 268,
    tDEFAULT = 269,
    tFOR = 270,
    tWHILE = 271,
    tDO = 272,
    tBREAK = 273,
    tCONTINUE = 274,
    tAND = 275,
    tOR = 276,
    tTRUE = 277,
    tFALSE = 278,
    tACCO = 279,
    tACCF = 280,
    tPARO = 281,
    tPARF = 282,
    tCROO = 283,
    tCROF = 284,
    tPLUS = 285,
    tMINUS = 286,
    tDIV = 287,
    tSTAR = 288,
    tMOD = 289,
    tEQUAL = 290,
    tSEMI = 291,
    tCOMMA = 292,
    tNOT = 293,
    tINC = 294,
    tDEC = 295,
    tID = 296,
    tNBR = 297
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_HOME_TERAE_DOCUMENTS_INSA_4A_IR_2EME_SEMESTRE_AUTOMATES_ET_LANGAGE_COMPILER_CMAKE_BUILD_DEBUG_SRC_SYNTAX_H_INCLUDED  */
