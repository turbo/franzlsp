






                                   CCHHAAPPTTEERR  77


                                TThhee LLiisspp RReeaaddeerr






             77..11..  IInnttrroodduuccttiioonn

                     The _r_e_a_d function is responsible for converting a
                stream of characters into a Lisp expression.  _R_e_a_d  is
                table  driven  and  the  table  it  uses  is  called a
                _r_e_a_d_t_a_b_l_e_.  The _p_r_i_n_t function  does  the  inverse  of
                _r_e_a_d;  it  converts a Lisp expression into a stream of
                characters.  Typically the conversion is done in  such
                a  way  that if that stream of characters were read by
                _r_e_a_d, the result would be an expression equal  to  the
                one  _p_r_i_n_t  was  given.   _P_r_i_n_t must also refer to the
                readtable in order to determine how to format its out-
                put.   The  _e_x_p_l_o_d_e  function, which returns a list of
                characters rather than printing them,  must also refer
                to the readtable.

                     A  readtable  is  created  with the _m_a_k_e_r_e_a_d_t_a_b_l_e
                function, modified with  the  _s_e_t_s_y_n_t_a_x  function  and
                interrogated  with the _g_e_t_s_y_n_t_a_x function.  The struc-
                ture of a readtable is  hidden  from  the  user   -  a
                readtable  should  only  be manipulated with the three
                functions mentioned above.

                     There is one distinguished readtable  called  the
                _c_u_r_r_e_n_t  _r_e_a_d_t_a_b_l_e  whose  value determines what _r_e_a_d,
                _p_r_i_n_t and _e_x_p_l_o_d_e do.  The current  readtable  is  the
                value  of  the symbol _r_e_a_d_t_a_b_l_e.  Thus it is  possible
                to rapidly change the current syntax by lambda binding
                a  different  readtable to the symbol _r_e_a_d_t_a_b_l_e_.  When
                the binding is undone, the syntax reverts to  its  old
                form.



             77..22..  SSyynnttaaxx CCllaasssseess

                     The readtable describes how each of the 128 ascii
                characters  should  be  treated  by  the  reader   and
                printer.   Each  character  belongs  to a _s_y_n_t_a_x _c_l_a_s_s
                which has three properties:

                character class -
                     Tells what the reader should do when it sees this


          TThhee LLiisspp RReeaaddeerr                                          77--11







          TThhee LLiisspp RReeaaddeerr                                          77--22


                     character.  There are a large number of character
                     classes.  They are described below.

                separator -
                     Most types of tokens the  reader  constructs  are
                     one  character  long.   Four  token types have an
                     arbitrary length:  number  (1234),  symbol  print
                     name   (franz),   escaped   symbol   print   name
                     (|franz|), and string ("franz").  The reader  can
                     easily  determine  when it has come to the end of
                     one of the last two types: it just looks for  the
                     matching  delimiter (| or ").  When the reader is
                     reading a number or symbol print name,  it  stops
                     reading  when  it  comes  to a character with the
                     _s_e_p_a_r_a_t_o_r property.  The separator  character  is
                     pushed back into the input stream and will be the
                     first character read when the  reader  is  called
                     again.

                escape -
                     Tells  the  printer  when to put escapes in front
                     of, or around, a symbol whose print name contains
                     this  character.   There are three possibilities:
                     always escape a symbol with this character in it,
                     only  escape a symbol if this is the only charac-
                     ter in the symbol, and only escape  a  symbol  if
                     this  is  the  first  character  in  the  symbol.
                     [note: The printer will always  escape  a  symbol
                     which,  if  printed  out, would look like a valid
                     number.]

                     When the Lisp system is built, Lisp code is added
                to  a  C-coded kernel and the result becomes the stan-
                dard lisp system.  The readtable  present  in  the  C-
                coded  kernel,  called the _r_a_w _r_e_a_d_t_a_b_l_e, contains the
                bare necessities for reading in Lisp code.  During the
                construction  of  the  complete Lisp system, a copy is
                made of the raw readtable and then the copy  is  modi-
                fied  by  adding macro characters.  The result is what
                is  called  the  _s_t_a_n_d_a_r_d  _r_e_a_d_t_a_b_l_e.   When   a   new
                readtable  is  created  with  _m_a_k_e_r_e_a_d_t_a_b_l_e_, a copy is
                made of  either  the  raw  readtable  or  the  current
                readtable   (which   is  likely  to  be  the  standard
                readtable).



             77..33..  RReeaaddeerr OOppeerraattiioonnss

                     The reader has a very simple  algorithm.   It  is
                either  _s_c_a_n_n_i_n_g  for  a token, _c_o_l_l_e_c_t_i_n_g a token, or
                _p_r_o_c_e_s_s_i_n_g a token.  Scanning involves reading charac-
                ters  and throwing away those which don't start tokens


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                          77--33


                (such as blanks and tabs).  Collecting means gathering
                the  characters  which  make up a token into a buffer.
                Processing  may  involve  creating  symbols,  strings,
                lists,  fixnums,  bignums or flonums or calling a user
                written function called a character macro.

                     The components of the syntax class determine when
                the  reader  switches between the scanning, collecting
                and processing states.  The reader will continue scan-
                ning  as long as the character class of the characters
                it reads is _c_s_e_p_a_r_a_t_o_r_.  When  it  reads  a  character
                whose character class is not _c_s_e_p_a_r_a_t_o_r it stores that
                character in its  buffer  and  begins  the  collecting
                phase.

                     If the character class of that first character is
                _c_c_h_a_r_a_c_t_e_r, _c_n_u_m_b_e_r, _c_p_e_r_i_o_d, or _c_s_i_g_n.  then it  will
                continue  collecting  until  it  runs into a character
                whose syntax class has the _s_e_p_a_r_a_t_o_r property.   (That
                last  character  will  be  pushed  back into the input
                buffer and will  be  the  first  character  read  next
                time.)  Now the reader goes into the processing phase,
                checking to see if the token it read is  a  number  or
                symbol.  It is important to note that  after the first
                character is collected the  component  of  the  syntax
                class  which  tells  the reader to  stop collecting is
                the _s_e_p_a_r_a_t_o_r property, not the character class.

                     If the character class  of  the  character  which
                stopped  the scanning is not _c_c_h_a_r_a_c_t_e_r, _c_n_u_m_b_e_r, _c_p_e_-
                _r_i_o_d, or _c_s_i_g_n.  then the reader processes that  char-
                acter  immediately.   The  character  classes _c_s_i_n_g_l_e_-
                _m_a_c_r_o, _c_s_i_n_g_l_e_-_s_p_l_i_c_i_n_g_-_m_a_c_r_o, and _c_s_i_n_g_l_e_-_i_n_f_i_x_-_m_a_c_r_o
                will act like _c_c_h_a_r_a_c_t_e_r if the following token is not
                a _s_e_p_a_r_a_t_o_r_.  The processing which is done for a given
                character  class  is  described  in detail in the next
                section.



             77..44..  CChhaarraacctteerr CCllaasssseess


          _c_c_h_a_r_a_c_t_e_r    raw readtable:A-Z a-z ^H !#$%&*,/:;<=>?@^_`{}~
                      standard readtable:A-Z a-z ^H !$%&*/:;<=>?@^_{}~
                A normal character.


          _c_n_u_m_b_e_r                                    raw readtable:0-9
                                                standard readtable:0-9
                This type is a  digit.   The  syntax  for  an  integer
                (fixnum  or  bignum) is a string of _c_n_u_m_b_e_r characters
                optionally followed by a _c_p_e_r_i_o_d_.  If the  digits  are


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                          77--44


                not  followed  by a _c_p_e_r_i_o_d, then they are interpreted
                in base _i_b_a_s_e which must be eight or ten.  The  syntax
                for  a  floating  point  number is either zero or more
                _c_n_u_m_b_e_r's followed by a _c_p_e_r_i_o_d and then  followed  by
                one  or  more  _c_n_u_m_b_e_r's.  A floating point number may
                also be  an integer or floating point number  followed
                by 'e' or 'd', an optional '+' or '-' and then zero or
                more _c_n_u_m_b_e_r's.


          _c_s_i_g_n                                       raw readtable:+-
                                                 standard readtable:+-
                A leading sign for  a  number.   No  other  characters
                should be given this class.


          _c_l_e_f_t_-_p_a_r_e_n                                  raw readtable:(
                                                  standard readtable:(
                A left parenthesis.  Tells the reader to begin forming
                a list.


          _c_r_i_g_h_t_-_p_a_r_e_n                                 raw readtable:)
                                                  standard readtable:)
                A right parenthesis.  Tells the  reader  that  it  has
                reached the end of a list.


          _c_l_e_f_t_-_b_r_a_c_k_e_t                                raw readtable:[
                                                  standard readtable:[
                A left bracket.  Tells the reader that it should begin
                forming a list.  See the description of _c_r_i_g_h_t_-_b_r_a_c_k_e_t
                for  the  difference  between cleft-bracket and cleft-
                paren.


          _c_r_i_g_h_t_-_b_r_a_c_k_e_t                               raw readtable:]
                                                  standard readtable:]
                A right bracket.  A _c_r_i_g_h_t_-_b_r_a_c_k_e_t finishes the forma-
                tion of the current list and all enclosing lists until
                it finds one which  begins  with  a  _c_l_e_f_t_-_b_r_a_c_k_e_t  or
                until it reaches the top level list.


          _c_p_e_r_i_o_d                                      raw readtable:.
                                                  standard readtable:.
                The  period is used to separate element of a cons cell
                [e.g. (a . (b . nil)) is the same as (a b)].   _c_p_e_r_i_o_d
                is also used in numbers as described above.


          _c_s_e_p_a_r_a_t_o_r                     raw readtable:^I-^M esc space
                                    standard readtable:^I-^M esc space


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                          77--55


                Separates  tokens.  When the reader is scanning, these
                character are passed over.  Note: there is  a  differ-
                ence  between  the  _c_s_e_p_a_r_a_t_o_r character class and the
                _s_e_p_a_r_a_t_o_r property of a syntax class.


          _c_s_i_n_g_l_e_-_q_u_o_t_e                                raw readtable:'
                                                  standard readtable:'
                This causes _r_e_a_d to be called recursively and the list
                (quote <value read>) to be returned.


          _c_s_y_m_b_o_l_-_d_e_l_i_m_i_t_e_r                            raw readtable:|
                                                  standard readtable:|
                This  causes the reader to begin collecting characters
                and to  stop  only  when  another  identical  _c_s_y_m_b_o_l_-
                _d_e_l_i_m_i_t_e_r  is seen.  The only way to escape a _c_s_y_m_b_o_l_-
                _d_e_l_i_m_i_t_e_r within a symbol name is with a _c_e_s_c_a_p_e char-
                acter.   The collected characters are converted into a
                string which becomes the print name of a symbol.  If a
                symbol  with  an  identical print name already exists,
                then the allocation is not done, rather  the  existing
                symbol is used.


          _c_e_s_c_a_p_e                                      raw readtable:\
                                                  standard readtable:\
                This  causes  the  next  character  to  read  in to be
                treated as a vvcchhaarraacctteerr.   A  character  whose  syntax
                class  is  vvcchhaarraacctteerr has a character class _c_c_h_a_r_a_c_t_e_r
                and does not have the _s_e_p_a_r_a_t_o_r property  so  it  will
                not separate symbols.


          _c_s_t_r_i_n_g_-_d_e_l_i_m_i_t_e_r                            raw readtable:"
                                                  standard readtable:"
                This  is  the  same  as  _c_s_y_m_b_o_l_-_d_e_l_i_m_i_t_e_r  except the
                result is returned as a string instead of a symbol.


          _c_s_i_n_g_l_e_-_c_h_a_r_a_c_t_e_r_-_s_y_m_b_o_l                  raw readtable:none
                                               standard readtable:none
                This returns a symbol whose print name is the the sin-
                gle character which has been collected.


          _c_m_a_c_r_o                                    raw readtable:none
                                                 standard readtable:`,
                The  reader  calls  the macro function associated with
                this character and the current readtable,  passing  it
                no arguments.  The result of the macro is added to the
                structure the reader is building, just as if that form
                were  directly  read  by  the reader.  More details on


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                          77--66


                macros are provided below.


          _c_s_p_l_i_c_i_n_g_-_m_a_c_r_o                           raw readtable:none
                                                 standard readtable:#;
                A _c_s_p_l_i_c_i_n_g_-_m_a_c_r_o differs from a _c_m_a_c_r_o in the way the
                result  is incorporated in the structure the reader is
                building.  A _c_s_p_l_i_c_i_n_g_-_m_a_c_r_o must  return  a  list  of
                forms (possibly empty).  The reader acts as if it read
                each element of the list itself without the  surround-
                ing parenthesis.


          _c_s_i_n_g_l_e_-_m_a_c_r_o                             raw readtable:none
                                               standard readtable:none
                This causes to reader to check the next character.  If
                it is a _c_s_e_p_a_r_a_t_o_r then this acts like a _c_m_a_c_r_o_.  Oth-
                erwise, it acts like a _c_c_h_a_r_a_c_t_e_r_.


          _c_s_i_n_g_l_e_-_s_p_l_i_c_i_n_g_-_m_a_c_r_o                    raw readtable:none
                                               standard readtable:none
                This  is  triggered  like  a _c_s_i_n_g_l_e_-_m_a_c_r_o however the
                result is spliced in like a _c_s_p_l_i_c_i_n_g_-_m_a_c_r_o_.


          _c_i_n_f_i_x_-_m_a_c_r_o                              raw readtable:none
                                               standard readtable:none
                This is differs from a _c_m_a_c_r_o in that the macro  func-
                tion is passed a form representing what the reader has
                read so far.  The result of the  macro  replaces  what
                the reader had read so far.


          _c_s_i_n_g_l_e_-_i_n_f_i_x_-_m_a_c_r_o                       raw readtable:none
                                               standard readtable:none
                This  differs  from the _c_i_n_f_i_x_-_m_a_c_r_o in that the macro
                will only be triggered if the character following  the
                _c_s_i_n_g_l_e_-_i_n_f_i_x_-_m_a_c_r_o character is a _c_s_e_p_a_r_a_t_o_r.


          _c_i_l_l_e_g_a_l                 raw readtable:^@-^G^N-^Z^\-^_rubout
                              standard readtable:^@-^G^N-^Z^\-^_rubout
                The  characters cause the reader to signal an error if
                read.



             77..55..  SSyynnttaaxx CCllaasssseess

                     The readtable maps each character into  a  syntax
                class.   The  syntax  class  contains  three pieces of
                information: the character class, whether  this  is  a


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                          77--77


                separator,  and  the escape properties.  The first two
                properties are used by the reader,  the  last  by  the
                printer  (and  _e_x_p_l_o_d_e).   The initial lisp system has
                the following syntax classes defined.   The  user  may
                add  syntax  classes  with _a_d_d_-_s_y_n_t_a_x_-_c_l_a_s_s.  For each
                syntax class, we list the properties of the class  and
                which  characters  have  this syntax class by default.
                More information about each syntax class can be  found
                under  the description of the syntax class's character
                class.

          vvcchhaarraacctteerr    raw readtable:A-Z a-z ^H !#$%&*,/:;<=>?@^_`{}~
          _c_c_h_a_r_a_c_t_e_r  standard readtable:A-Z a-z ^H !$%&*/:;<=>?@^_{}~



          vvnnuummbbeerr                                    raw readtable:0-9
          _c_n_u_m_b_e_r                               standard readtable:0-9



          vvssiiggnn                                       raw readtable:+-
          _c_s_i_g_n                                  standard readtable:+-



          vvlleefftt--ppaarreenn                                  raw readtable:(
          _c_l_e_f_t_-_p_a_r_e_n                             standard readtable:(
          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r

          vvrriigghhtt--ppaarreenn                                 raw readtable:)
          _c_r_i_g_h_t_-_p_a_r_e_n                            standard readtable:)
          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r

          vvlleefftt--bbrraacckkeett                                raw readtable:[
          _c_l_e_f_t_-_b_r_a_c_k_e_t                           standard readtable:[
          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r

          vvrriigghhtt--bbrraacckkeett                               raw readtable:]
          _c_r_i_g_h_t_-_b_r_a_c_k_e_t                          standard readtable:]
          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r

          vvppeerriioodd                                      raw readtable:.
          _c_p_e_r_i_o_d                                 standard readtable:.
          _e_s_c_a_p_e_-_w_h_e_n_-_u_n_i_q_u_e


          vvsseeppaarraattoorr                     raw readtable:^I-^M esc space
          _c_s_e_p_a_r_a_t_o_r                standard readtable:^I-^M esc space


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                          77--88


          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r

          vvssiinnggllee--qquuoottee                                raw readtable:'
          _c_s_i_n_g_l_e_-_q_u_o_t_e                           standard readtable:'
          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r

          vvssyymmbbooll--ddeelliimmiitteerr                            raw readtable:|
          _c_s_i_n_g_l_e_-_d_e_l_i_m_i_t_e_r                       standard readtable:|
          _e_s_c_a_p_e_-_a_l_w_a_y_s


          vveessccaappee                                      raw readtable:\
          _c_e_s_c_a_p_e                                 standard readtable:\
          _e_s_c_a_p_e_-_a_l_w_a_y_s


          vvssttrriinngg--ddeelliimmiitteerr                            raw readtable:"
          _c_s_t_r_i_n_g_-_d_e_l_i_m_i_t_e_r                       standard readtable:"
          _e_s_c_a_p_e_-_a_l_w_a_y_s


          vvssiinnggllee--cchhaarraacctteerr--ssyymmbbooll                  raw readtable:none
          _c_s_i_n_g_l_e_-_c_h_a_r_a_c_t_e_r_-_s_y_m_b_o_l             standard readtable:none
          _s_e_p_a_r_a_t_o_r


          vvmmaaccrroo                                    raw readtable:none
          _c_m_a_c_r_o                                 standard readtable:`,
          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r

          vvsspplliicciinngg--mmaaccrroo                           raw readtable:none
          _c_s_p_l_i_c_i_n_g_-_m_a_c_r_o                        standard readtable:#;
          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r

          vvssiinnggllee--mmaaccrroo                             raw readtable:none
          _c_s_i_n_g_l_e_-_m_a_c_r_o                        standard readtable:none
          _e_s_c_a_p_e_-_w_h_e_n_-_u_n_i_q_u_e


          vvssiinnggllee--sspplliicciinngg--mmaaccrroo                    raw readtable:none
          _c_s_i_n_g_l_e_-_s_p_l_i_c_i_n_g_-_m_a_c_r_o               standard readtable:none
          _e_s_c_a_p_e_-_w_h_e_n_-_u_n_i_q_u_e


          vviinnffiixx--mmaaccrroo                              raw readtable:none
          _c_i_n_f_i_x_-_m_a_c_r_o                         standard readtable:none
          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r



                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                          77--99


          vvssiinnggllee--iinnffiixx--mmaaccrroo                       raw readtable:none
          _c_s_i_n_g_l_e_-_i_n_f_i_x_-_m_a_c_r_o                  standard readtable:none
          _e_s_c_a_p_e_-_w_h_e_n_-_u_n_i_q_u_e


          vviilllleeggaall                 raw readtable:^@-^G^N-^Z^\-^_rubout
          _c_i_l_l_e_g_a_l            standard readtable:^@-^G^N-^Z^\-^_rubout
          _e_s_c_a_p_e_-_a_l_w_a_y_s
          _s_e_p_a_r_a_t_o_r



             77..66..  CChhaarraacctteerr MMaaccrrooss

                     Character macros are user written functions which
                are  executed  during  the reading process.  The value
                returned by a character macro may or may not  be  used
                by  the reader, depending on the type of macro and the
                value returned.  Character macros are always  attached
                to a single character with the _s_e_t_s_y_n_t_a_x function.



                77..66..11..   TTyyppeess    There  are  three types of character
                   macros: normal, splicing and  infix.   These  types
                   differ  in  the arguments they are given or in what
                   is done with the result they return.



                   77..66..11..11..  NNoorrmmaall

                           A normal macro is passed no arguments.  The
                      value  returned by a normal macro is simply used
                      by the reader  as  if  it  had  read  the  value
                      itself.   Here  is  an  example of a macro which
                      returns the abbreviation for a given state.


              ____________________________________________________

              ->_(_d_e_f_u_n _s_t_a_t_e_a_b_b_r_e_v _n_i_l
                    _(_c_d_r _(_a_s_s_q _(_r_e_a_d_) _'_(_(_c_a_l_i_f_o_r_n_i_a _. _c_a_) _(_p_e_n_n_s_y_l_v_a_n_i_a _. _p_a_)_)_)_)_)
              stateabbrev
              -> _(_s_e_t_s_y_n_t_a_x _'_\_! _'_v_m_a_c_r_o _'_s_t_a_t_e_a_b_b_r_e_v_)
              t
              -> _'_( _! _c_a_l_i_f_o_r_n_i_a _! _w_y_o_m_i_n_g _! _p_e_n_n_s_y_l_v_a_n_i_a_)
              (ca nil pa)
              ____________________________________________________



          Notice what happened to


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                         77--1100


           _! _w_y_o_m_i_n_g.  Since it wasn't in the  table,  the  associated
          function  returned  nil.   The creator of the macro may have
          wanted to leave the list alone, in such a case, but couldn't
          with  this  type  of  reader  macro.   The  splicing  macro,
          described next, allows a character macro function to  return
          a value that is ignored.



                   77..66..11..22..  SSpplliicciinngg

                           The  value  returned  from a splicing macro
                      must be a list or nil.  If  the  value  is  nil,
                      then  the value is ignored, otherwise the reader
                      acts as if it read  each  object  in  the  list.
                      Usually  the list only contains one element.  If
                      the reader is reading at the top level (i.e. not
                      collecting elements of list), then it is illegal
                      for a splicing macro to  return  more  then  one
                      element  in  the list.  The major advantage of a
                      splicing macro over a normal macro is the  abil-
                      ity  of  the  splicing  macro to return nothing.
                      The comment character (usually ;) is a  splicing
                      macro bound to a function which reads to the end
                      of the line and always returns nil.  Here is the
                      previous example written as a splicing macro


              ____________________________________________________

              -> _(_d_e_f_u_n _s_t_a_t_e_a_b_b_r_e_v _n_i_l
                    _(_(_l_a_m_b_d_a _(_v_a_l_u_e_)
                          _(_c_o_n_d _(_v_a_l_u_e _(_l_i_s_t _v_a_l_u_e_)_)
                                 _(_t _n_i_l_)_)_)
                      _(_c_d_r _(_a_s_s_q _(_r_e_a_d_) _'_(_(_c_a_l_i_f_o_r_n_i_a _. _c_a_) _(_p_e_n_n_s_y_l_v_a_n_i_a _. _p_a_)_)_)_)_)_)
              -> _(_s_e_t_s_y_n_t_a_x _'_! _'_v_s_p_l_i_c_i_n_g_-_m_a_c_r_o _'_s_t_a_t_e_a_b_b_r_e_v_)
              -> _'_(_!_p_e_n_n_s_y_l_v_a_n_i_a _! _f_o_o _!_c_a_l_i_f_o_r_n_i_a_)
              (pa ca)
              -> _'_!_f_o_o _!_b_a_r _!_p_e_n_n_s_y_l_v_a_n_i_a
              pa
              ->
              ____________________________________________________






                   77..66..11..33..  IInnffiixx

                           Infix  macros  are  passed a _c_o_n_c structure
                      representing  what  has  been   read   so   far.
                      Briefly, a tconc structure is a single list cell


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                         77--1111


                      whose car points to a list and whose cdr  points
                      to  the last list cell in that list.  The inter-
                      pretation by the reader of the value returned by
                      an  infix  macro depends on whether the macro is
                      called while the reader is constructing  a  list
                      or  whether it is called at the top level of the
                      reader.  If the macro is called while a list  is
                      being   constructed,  then  the  value  returned
                      should be  a tconc structure.  The car  of  that
                      structure replaces the list of elements that the
                      reader has been collecting.   If  the  macro  is
                      called  at top level, then it will be passed the
                      value nil,  and  the  value  it  returns  should
                      either  be  nil  or  a  tconc structure.  If the
                      macro returns nil, then the value is ignored and
                      the  reader  continues  to  read.   If the macro
                      returns a tconc structure of one  element  (i.e.
                      whose  car  is a list of one element), then that
                      single element is returned as the value of _r_e_a_d_.
                      If  the  macro returns a tconc structure of more
                      than one element, then that list of elements  is
                      returned as the value of read.


              ____________________________________________________

              -> _(_d_e_f_u_n _p_l_u_s_o_p _(_x_)
                       _(_c_o_n_d _(_(_n_u_l_l _x_) _(_t_c_o_n_c _n_i_l _'_\_+_)_)
                             _(_t _(_l_c_o_n_c _n_i_l _(_l_i_s_t _'_p_l_u_s _(_c_a_a_r _x_) _(_r_e_a_d_)_)_)_)_)_)

              plusop
              -> _(_s_e_t_s_y_n_t_a_x _'_\_+ _'_v_i_n_f_i_x_-_m_a_c_r_o _'_p_l_u_s_o_p_)
              t
              -> _'_(_a _+ _b_)
              (plus a b)
              -> _'_+
              |+|
              ->
              ____________________________________________________






                77..66..22..  IInnvvooccaattiioonnss

                        There  are  three  different  circumstances in
                   which you would like a macro function to  be  trig-
                   gered.

                   _A_l_w_a_y_s _-
                        Whenever  the  macro  character  is  seen, the


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                         77--1122


                        macro should be invoked.  This is accomplished
                        by using the character classes _c_m_a_c_r_o, _c_s_p_l_i_c_-
                        _i_n_g_-_m_a_c_r_o, or _c_i_n_f_i_x_-_m_a_c_r_o, and by  using  the
                        _s_e_p_a_r_a_t_o_r   property.    The   syntax  classes
                        vvmmaaccrroo, vvsspplliicciinngg--mmaaccrroo, and vvssiinnggllee--mmaaccrroo are
                        defined this way.

                   _W_h_e_n _f_i_r_s_t _-
                        The  macro  should  only be triggered when the
                        macro character is the first  character  found
                        after  the  scanning  process.  A syntax class
                        for a _w_h_e_n _f_i_r_s_t macro would be defined  using
                        _c_m_a_c_r_o,  _c_s_p_l_i_c_i_n_g_-_m_a_c_r_o,  or _c_i_n_f_i_x_-_m_a_c_r_o and
                        not including the _s_e_p_a_r_a_t_o_r property.

                   _W_h_e_n _u_n_i_q_u_e _-
                        The macro should only be  triggered  when  the
                        macro  character  is  the  only character col-
                        lected in the token collection  phase  of  the
                        reader,  i.e  the macro character is preceeded
                        by zero or more _c_s_e_p_a_r_a_t_o_rs and followed by  a
                        _s_e_p_a_r_a_t_o_r_.   A  syntax class for a _w_h_e_n _u_n_i_q_u_e
                        macro would be  defined  using  _c_s_i_n_g_l_e_-_m_a_c_r_o,
                        _c_s_i_n_g_l_e_-_s_p_l_i_c_i_n_g_-_m_a_c_r_o, or _c_s_i_n_g_l_e_-_i_n_f_i_x_-_m_a_c_r_o
                        and not including the _s_e_p_a_r_a_t_o_r property.  The
                        syntax  classes  so defined are vvssiinnggllee--mmaaccrroo,
                        vvssiinnggllee--sspplliicciinngg--mmaaccrroo,   and   vvssiinnggllee--iinnffiixx--
                        mmaaccrroo.



             77..77..  FFuunnccttiioonnss

          ((sseettssyynnttaaxx 's_symbol 's_synclass ['ls_func]))

               WHERE:   ls_func  is the name of a function or a lambda
                        body.

               RETURNS: t

               SIDE EFFECT: S_symbol should be a  symbol  whose  print
                            name  is  only  one character.  The syntax
                            class  for  that  character  is   set   to
                            s_synclass  in  the current readtable.  If
                            s_synclass is  a  class  that  requires  a
                            character macro, then ls_func must be sup-
                            plied.

               NOTE: The symbolic syntax codes are  new  to  Opus  38.
                     For  compatibility,  s_synclass can be one of the
                     fixnum syntax codes which appeared in older  ver-
                     sions of the FRANZ LISP Manual.  This compatibil-
                     ity is only temporary: existing code  which  uses


                                             Printed: October 16, 1993







          TThhee LLiisspp RReeaaddeerr                                         77--1133


                     the fixnum syntax codes should be converted.

          ((ggeettssyynnttaaxx 's_symbol))

               RETURNS: the  syntax  class  of  the first character of
                        s_symbol's print name.  s_symbol's print  name
                        must be exactly one character long.

               NOTE: This  function  is new to Opus 38.  It supercedes
                     _(_s_t_a_t_u_s _s_y_n_t_a_x_) which no longer exists.

          ((aadddd--ssyynnttaaxx--ccllaassss 's_synclass 'l_properties))

               RETURNS: s_synclass

               SIDE EFFECT: Defines the  syntax  class  s_synclass  to
                            have  properties  l_properties.   The list
                            l_properties should  contain  a  character
                            classes mentioned above.  l_properties may
                            contain  one  of  the  escape  properties:
                            _e_s_c_a_p_e_-_a_l_w_a_y_s,    _e_s_c_a_p_e_-_w_h_e_n_-_u_n_i_q_u_e,   or
                            _e_s_c_a_p_e_-_w_h_e_n_-_f_i_r_s_t.  l_properties may  con-
                            tain the _s_e_p_a_r_a_t_o_r property.  After a syn-
                            tax  class  has  been  defined  with  _a_d_d_-
                            _s_y_n_t_a_x_-_c_l_a_s_s,  the  _s_e_t_s_y_n_t_a_x function can
                            be used to  give  characters  that  syntax
                            class.


              ____________________________________________________

              ; Define a non-separating macro character.
              ; This type of macro character is used in UCI-Lisp, and
              ; it corresponds to a  FIRST MACRO in Interlisp
              -> _(_a_d_d_-_s_y_n_t_a_x_-_c_l_a_s_s _'_v_u_c_i_-_m_a_c_r_o _'_(_c_m_a_c_r_o _e_s_c_a_p_e_-_w_h_e_n_-_f_i_r_s_t_)_)
              vuci-macro
              ->
              ____________________________________________________

















                                             Printed: October 16, 1993



