/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_GENERATED_CODE_PARSER_H_INCLUDED
# define YY_YY_GENERATED_CODE_PARSER_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    Token_String = 258,            /* Token_String  */
    Token_Number = 259,            /* Token_Number  */
    Token_KeyCode = 260,           /* Token_KeyCode  */
    Token_Label = 261,             /* Token_Label  */
    NOP = 262,                     /* NOP  */
    ADD = 263,                     /* ADD  */
    SUB = 264,                     /* SUB  */
    MUL = 265,                     /* MUL  */
    DIV = 266,                     /* DIV  */
    HLT = 267,                     /* HLT  */
    NUM = 268,                     /* NUM  */
    CHR = 269,                     /* CHR  */
    SLA = 270,                     /* SLA  */
    SRA = 271,                     /* SRA  */
    SLAX = 272,                    /* SLAX  */
    SRAX = 273,                    /* SRAX  */
    SLC = 274,                     /* SLC  */
    SRC = 275,                     /* SRC  */
    MOVE = 276,                    /* MOVE  */
    LDA = 277,                     /* LDA  */
    LD1 = 278,                     /* LD1  */
    LD2 = 279,                     /* LD2  */
    LD3 = 280,                     /* LD3  */
    LD4 = 281,                     /* LD4  */
    LD5 = 282,                     /* LD5  */
    LD6 = 283,                     /* LD6  */
    LDX = 284,                     /* LDX  */
    LDAN = 285,                    /* LDAN  */
    LD1N = 286,                    /* LD1N  */
    LD2N = 287,                    /* LD2N  */
    LD3N = 288,                    /* LD3N  */
    LD4N = 289,                    /* LD4N  */
    LD5N = 290,                    /* LD5N  */
    LD6N = 291,                    /* LD6N  */
    LDXN = 292,                    /* LDXN  */
    STA = 293,                     /* STA  */
    ST1 = 294,                     /* ST1  */
    ST2 = 295,                     /* ST2  */
    ST3 = 296,                     /* ST3  */
    ST4 = 297,                     /* ST4  */
    ST5 = 298,                     /* ST5  */
    ST6 = 299,                     /* ST6  */
    STX = 300,                     /* STX  */
    STJ = 301,                     /* STJ  */
    STZ = 302,                     /* STZ  */
    IOC = 303,                     /* IOC  */
    IN = 304,                      /* IN  */
    OUT = 305,                     /* OUT  */
    JMP = 306,                     /* JMP  */
    JSJ = 307,                     /* JSJ  */
    JOV = 308,                     /* JOV  */
    JNOV = 309,                    /* JNOV  */
    JL = 310,                      /* JL  */
    JE = 311,                      /* JE  */
    JG = 312,                      /* JG  */
    JGE = 313,                     /* JGE  */
    JNE = 314,                     /* JNE  */
    JLE = 315,                     /* JLE  */
    JAN = 316,                     /* JAN  */
    J1N = 317,                     /* J1N  */
    J2N = 318,                     /* J2N  */
    J3N = 319,                     /* J3N  */
    J4N = 320,                     /* J4N  */
    J5N = 321,                     /* J5N  */
    J6N = 322,                     /* J6N  */
    JXN = 323,                     /* JXN  */
    JAZ = 324,                     /* JAZ  */
    J1Z = 325,                     /* J1Z  */
    J2Z = 326,                     /* J2Z  */
    J3Z = 327,                     /* J3Z  */
    J4Z = 328,                     /* J4Z  */
    J5Z = 329,                     /* J5Z  */
    J6Z = 330,                     /* J6Z  */
    JXZ = 331,                     /* JXZ  */
    JAP = 332,                     /* JAP  */
    J1P = 333,                     /* J1P  */
    J2P = 334,                     /* J2P  */
    J3P = 335,                     /* J3P  */
    J4P = 336,                     /* J4P  */
    J5P = 337,                     /* J5P  */
    J6P = 338,                     /* J6P  */
    JXP = 339,                     /* JXP  */
    JANN = 340,                    /* JANN  */
    J1NN = 341,                    /* J1NN  */
    J2NN = 342,                    /* J2NN  */
    J3NN = 343,                    /* J3NN  */
    J4NN = 344,                    /* J4NN  */
    J5NN = 345,                    /* J5NN  */
    J6NN = 346,                    /* J6NN  */
    JXNN = 347,                    /* JXNN  */
    JANZ = 348,                    /* JANZ  */
    J1NZ = 349,                    /* J1NZ  */
    J2NZ = 350,                    /* J2NZ  */
    J3NZ = 351,                    /* J3NZ  */
    J4NZ = 352,                    /* J4NZ  */
    J5NZ = 353,                    /* J5NZ  */
    J6NZ = 354,                    /* J6NZ  */
    JXNZ = 355,                    /* JXNZ  */
    JANP = 356,                    /* JANP  */
    J1NP = 357,                    /* J1NP  */
    J2NP = 358,                    /* J2NP  */
    J3NP = 359,                    /* J3NP  */
    J4NP = 360,                    /* J4NP  */
    J5NP = 361,                    /* J5NP  */
    J6NP = 362,                    /* J6NP  */
    JXNP = 363,                    /* JXNP  */
    INCA = 364,                    /* INCA  */
    INC1 = 365,                    /* INC1  */
    INC2 = 366,                    /* INC2  */
    INC3 = 367,                    /* INC3  */
    INC4 = 368,                    /* INC4  */
    INC5 = 369,                    /* INC5  */
    INC6 = 370,                    /* INC6  */
    INCX = 371,                    /* INCX  */
    DECA = 372,                    /* DECA  */
    DEC1 = 373,                    /* DEC1  */
    DEC2 = 374,                    /* DEC2  */
    DEC3 = 375,                    /* DEC3  */
    DEC4 = 376,                    /* DEC4  */
    DEC5 = 377,                    /* DEC5  */
    DEC6 = 378,                    /* DEC6  */
    DECX = 379,                    /* DECX  */
    ENTA = 380,                    /* ENTA  */
    ENT1 = 381,                    /* ENT1  */
    ENT2 = 382,                    /* ENT2  */
    ENT3 = 383,                    /* ENT3  */
    ENT4 = 384,                    /* ENT4  */
    ENT5 = 385,                    /* ENT5  */
    ENT6 = 386,                    /* ENT6  */
    ENTX = 387,                    /* ENTX  */
    ENNA = 388,                    /* ENNA  */
    ENN1 = 389,                    /* ENN1  */
    ENN2 = 390,                    /* ENN2  */
    ENN3 = 391,                    /* ENN3  */
    ENN4 = 392,                    /* ENN4  */
    ENN5 = 393,                    /* ENN5  */
    ENN6 = 394,                    /* ENN6  */
    ENNX = 395,                    /* ENNX  */
    CMPA = 396,                    /* CMPA  */
    CMP1 = 397,                    /* CMP1  */
    CMP2 = 398,                    /* CMP2  */
    CMP3 = 399,                    /* CMP3  */
    CMP4 = 400,                    /* CMP4  */
    CMP5 = 401,                    /* CMP5  */
    CMP6 = 402,                    /* CMP6  */
    CMP7 = 403                     /* CMP7  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 26 "./Source/Parser.ym"

    char *stringValue;
    int numericValue;

#line 217 "./Generated-Code/Parser.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif




int yyparse (void *scanner, id <ParserConsumer> consumer);


#endif /* !YY_YY_GENERATED_CODE_PARSER_H_INCLUDED  */
