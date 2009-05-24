;; The first three lines of this file were inserted by DrScheme. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "reader.ss" "plai" "lang")
;;-----------------------------------------------------------------------------
;; MAC0316 - Conceitos Fundamentais de Linguagens de Programação
;; 1o. semestre de 2009
;; Prof. Marco Dimas Gubitoso - gubi@ime.usp.br
;;
;; Aluno: André Jucovsky Bianchi
;; Número USP: 3682248
;; EP1 - CFMAE/L: Implementação de Funções com múltiplos argumentos.
;;-----------------------------------------------------------------------------


;; Este trabalho implementa funções com múltiplos argumentos na linguagem
;; CFAE/L, desenvolvendo uma nova linguagem, de nome CFMAE/L. As partes
;; marcadas com (*) no código são marcações nos trechos que foram modificados
;; para o funcionamento das funções com múltiplos argumentos.
;;
;;
;; Representação
;; -------------
;;
;; Os parâmetros são implementados como listas de símbolos (ParamList) e os
;; argumentos como listas de expressões (ArgList). A sintaxe para definição e
;; aplicação de funções fica da seguinte forma:
;;
;;   {fun {param list} {function body}}
;;   {app fun {arg list}}
;;
;; Por exemplo, uma função que soma o primeiro argumento com a multiplicação
;; dos dois argumentos seguintes ficaria da seguinte forma:
;;
;;   {fun {x y z} {+ x {* y z}}}
;;
;; E uma aplicação desta função aos argumentos x -> 10, y -> 20 e z -> 30,
;; escreve-se da seguinte forma:
;;
;;   {app f {10 20 30}}
;;
;;
;; Enriquecimento de ambiente
;; --------------------------
;;
;; A solução escolhida foi o enriquecimento do ambiente associado à função (na
;; clausura) com a lista de parâmetros associada à lista de valores indicados
;; no momento da aplicação da função. Quando o interpretador encontra uma
;; aplicação de função, enriquece o ambiente com as novas associações e em
;; seguida continua a interpretação da função como anteriormente.
;;
;;
;; Testes
;; ------
;;
;; No final do arquivo é possível encontrar alguns testes para a linguagem. A
;; primeira bateria de testes é a adaptação dos testes do livre no capítulo de
;; substituição para a linguagem atual, considerando os novos valores de
;; retorno e a necessidade da chamada da função 'strict' para a avaliação de
;; algumas expressões.
;;
;; A segunda bateria de testes verifica se a definição de múltiplos parâmetros
;; funciona bem. São testadas funções com 1, 2 e 3 parâmetros, e também funções
;; que reutilizam nomes de parâmetros, com o objetivo de testar a solidez dos
;; escopos.



;;-----------------------------------------------------------------------------
;; parser
;;-----------------------------------------------------------------------------


;; parse: sexp -> CFMAE/L
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(symbol? sexp) (id sexp)]
    [(list? sexp)
     (cond
       [(symbol? (first sexp))
        (case (first sexp)
          [(+) (add (parse (second sexp)) (parse (third sexp)))]
          [(-) (sub (parse (second sexp)) (parse (third sexp)))]
          [(*) (mul (parse (second sexp)) (parse (third sexp)))]
          [(/) (div (parse (second sexp)) (parse (third sexp)))]
          [(with) ;; (with (id value) body) -> (app (fun id body) value)
           (app (fun (parse-paramlist (list (first (second sexp))))      ;; (*)
                     (parse (third sexp)))
                (parse-arglist (list (second (second sexp)))))]          ;; (*)
          [(fun)
           (fun (parse-paramlist (second sexp))                          ;; (*)
                (parse (third sexp)))]
          [(app) ;; (app fun value)
           (app (parse (second sexp))
                (parse-arglist (third sexp)))])])]                       ;; (*)
       [(list? (first sexp)) ;; garante o parsing de parenteses aninhados
        (parse (first sexp))]))


;; parse-paramlist: (sexp) -> ParamList                                     (*)
(define (parse-paramlist list)
  (cond
    [(empty? list) (mtParam)]
    [else
     (aParam (first list) (parse-paramlist (rest list)))]))


;; parse-arglist: (sexp) -> ArgList                                         (*)
(define (parse-arglist list)
  (cond
    [(empty? list) (mtArg)]
    [else
     (anArg (parse (first list)) (parse-arglist (cdr list)))]))



;;-----------------------------------------------------------------------------
;; Tipos
;;-----------------------------------------------------------------------------


;; Tipo: CFMAE/L
;; Representa a linguagem com Condicionais, Funções de primeira classe com
;; múltiplos parâmetros e laziness.
(define-type CFMAE/L
  [num (n number?)]
  [add (lhs CFMAE/L?) (rhs CFMAE/L?)]
  [sub (lhs CFMAE/L?) (rhs CFMAE/L?)]
  [mul (lhs CFMAE/L?) (rhs CFMAE/L?)]
  [div (lhs CFMAE/L?) (rhs CFMAE/L?)]
  [id (name symbol?)]
  [fun (params ParamList?) (body CFMAE/L?)]                              ;; (*)
  [app (fun-expr CFMAE/L?) (args ArgList?)])                             ;; (*)


;; boxed-boolean/CFMAE/L-Value?: CFMAE/L -> boolean
;; Verifica se um valor é um boxed-boolean/CFMAE/L-Value
(define (boxed-boolean/CFMAE/L-Value? v)
  (and (box? v)
       (or (boolean? (unbox v))
           (numV? (unbox v))
           (closureV (unbox v)))))


;; Tipo: CFMAE/L-Value
;; Valores que o interpretador pode retornar.
(define-type CFMAE/L-Value
  [numV (n number?)]
  [closureV (params ParamList?)                                          ;; (*)
            (body CFMAE/L?)
            (env Env?)]
  [exprV (expr CFMAE/L?)
         (env Env?)
         (cache boxed-boolean/CFMAE/L-Value?)])


;; Tipo: Env
;; Um repositório de substituições deferidas.
(define-type Env
  [mtSub]
  [aSub (name symbol?)
        (value CFMAE/L-Value?)
        (env Env?)])


;; Tipo: ParamList                                                          (*)
;; Lista de parâmetros de funções.
(define-type ParamList
  [mtParam]
  [aParam (name symbol?)
          (paramlist ParamList?)])


;; Tipo: ArgList                                                            (*)
;; Lista de argumentos de funções.
(define-type ArgList
  [mtArg]
  [anArg (value CFMAE/L?)
          (arglist ArgList?)])



;;-----------------------------------------------------------------------------
;; Operações abstratas
;;-----------------------------------------------------------------------------


;; num+: CFMAE/L-Value, CFMAE/L-Value -> numV
(define (num+ n1 n2)
  (numV (+ (numV-n (strict n1)) (numV-n (strict n2)))))


;; num-: CFMAE/L-Value, CFMAE/L-Value -> numV
(define (num- n1 n2)
  (numV (- (numV-n (strict n1)) (numV-n (strict n2)))))


;; num*: CFMAE/L-Value, CFMAE/L-Value -> numV
(define (num* n1 n2)
  (numV (* (numV-n (strict n1)) (numV-n (strict n2)))))


;; num/: CFMAE/L-Value, CFMAE/L-Value -> numV
(define (num/ n1 n2)
  (numV (/ (numV-n (strict n1)) (numV-n (strict n2)))))


;; num-zero?: CFMAE/L-Value -> boolean
(define (num-zero? n)
  (zero? (numV-n (strict n))))



;;-----------------------------------------------------------------------------
;; Funções auxiliares
;;-----------------------------------------------------------------------------


;; lookup: Symbol, Env -> CFMAE/L
;; Retorna uma expressão CFMAE/L correspondente a um nome em um ambiente.
(define (lookup name env)
  (type-case Env env
             [mtSub () (error 'lookup "no binding for identifier")]
             [aSub (s-name s-value rest-env)
                   (if (symbol=? name s-name)
                       s-value
                       (lookup name rest-env))]))


;; lookup-param: Symbol, ParamList -> boolean
;; Procura um parâmetro numa lista.
(define (lookup-param name param)
  (type-case ParamList param
             [mtParam () false]                    ;; nao encontrou o parametro
             [aParam (pname plist)
                   (if (symbol=? name pname)
                       true                            ;; encontrou o parametro
                       (lookup-param name plist))]))


;; strict: CFMAE/L-Value -> CFMAE/L-Value 
;; Força a interpretação de uma substituição deferida (até o final).
(define (strict e)
  (type-case CFMAE/L-Value e
             [exprV (expr env cache)
                    (if (boolean? (unbox cache))
                        (local [(define the-value (strict (interp expr env)))]
                          (begin
                            (printf "Forcing exprV to ~a~n" the-value)
                            (set-box! cache the-value)
                            the-value))
                        (begin
                          (printf "Using cached value ~n")
                          (unbox cache)))]
             [else e]))



;;-----------------------------------------------------------------------------
;; Interpretador
;;-----------------------------------------------------------------------------


;; interp: CFMAE/L, Env -> CFMAE/L-Value
(define (interp expr env)
  (type-case CFMAE/L expr
             [num (n) (numV n)]
             [add (lhs rhs) (num+ (interp lhs env) (interp rhs env))]
             [sub (lhs rhs) (num- (interp lhs env) (interp rhs env))]
             [mul (lhs rhs) (num* (interp lhs env) (interp rhs env))]
             [div (lhs rhs) (num/ (interp lhs env) (interp rhs env))]
             [id (name) (lookup name env)]
             [fun (params body)
                  (closureV params body env)]
             [app (fun-expr arglist)
                  (local ([define fun-val
                            (strict (interp fun-expr env))] ;; fun-val=closureV
                          [define fun-env                                ;; (*)
                            (enrich-env (closureV-env fun-val)           ;; (*)
                                        (closureV-params fun-val)        ;; (*)
                                        arglist                          ;; (*)
                                        (mtParam))]);; nomes utilizados  ;; (*)
                    (interp (closureV-body fun-val) fun-env))]))         ;; (*)


;; enrich-env: Env Paramlist ArgList ParamList -> Env                    ;; (*)
;; Enriquece um ambiente com associações de parametros com argumentos.
(define (enrich-env env params args names)
  (type-case ParamList params
             [mtParam ()
                     (cond
                       [(mtArg? args) env] ;; mesmo numero de params e args
                       [else (error 'enrich-env "More args than params.")])]
             [aParam (pname plist)
                     (cond  ;; verifica se ja existe parametro com esse nome -.
                       [(lookup-param pname names) ;; <-----------------------'
                         (error 'enrich-env "Parameter name already used.")]
                       [else
                        (cond ;; verifica se há mais parâmetros que argumentos
                          [(mtArg? args)
                           (error 'enrich-env "More params than args.")]
                          [aParam
                           (aSub (aParam-name params)
                                 (exprV (anArg-value args);; <- lazy evaluation
                                        env (box false))
                                 (enrich-env env
                                             (aParam-paramlist params)
                                             (anArg-arglist args)
                                             (aParam (aParam-name params)
                                                     names)))])])]))
                                           ;; ^-- adiciona o nome do parametro
                                           ;;     'a lista de nomes ja
                                           ;;      utilizados.


;;-----------------------------------------------------------------------------
;; Testes
;;-----------------------------------------------------------------------------

;; Testes do livro levemente modificados, para a linguagem atual.
(test (interp (parse '5 ) (mtSub)) (numV 5))
(test (interp (parse '{+ 5 5} ) (mtSub)) (numV 10))
(test (interp (parse '{with {x {+ 5 5}} {+ x x}} ) (mtSub)) (numV 20))
(test (interp (parse '{with {x 5} {+ x x}} ) (mtSub)) (numV 10))
(test (interp (parse '{with {x {+ 5 5}} {with {y {- x 3}} {+ y y}}} ) (mtSub)) (numV 14))
(test (interp (parse '{with {x 5} {with {y {- x 3}} {+ y y}}} ) (mtSub)) (numV 4))
(test (interp (parse '{with {x 5} {+ x {with {x 3} 10}}} ) (mtSub)) (numV 15))
(test (interp (parse '{with {x 5} {+ x {with {x 3} x}}} ) (mtSub)) (numV 8))
(test (interp (parse '{with {x 5} {+ x {with {y 3} x}}} ) (mtSub)) (numV 10))
(test (strict (interp (parse '{with {x 5} {with {y x} y}} ) (mtSub))) (numV 5))
(test (strict (interp (parse '{with {x 5} {with {x x} x}} ) (mtSub))) (numV 5))

;; Testes com funções
(test (interp (parse '{with {x {fun {x} {+ x x}}} {app x {10}}} ) (mtSub)) (numV 20))
(test (interp (parse '{with {x {fun {x z} {+ x {* 2 z}}}} {app x {10 {+ 10 10}}}} ) (mtSub)) (numV 50))
(test (interp (parse '{with {sum3 {fun {a b c} {+ a {+ b c}}}} {app sum3 {{+ 1 2} 4 {- 3 2}}}} ) (mtSub)) (numV 8))
