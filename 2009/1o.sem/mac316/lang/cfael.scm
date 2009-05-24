;; The first three lines of this file were inserted by DrScheme. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "reader.ss" "plai" "lang")
;; The first three lines of this file were inserted by DrScheme. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "reader.ss" "plai" "lang")
;; parse: sexp -> CFAE/L
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
           (app (fun (first (second sexp)) (parse (third sexp)))
                (parse (second (second sexp))))]
          [(fun) (fun (first (second sexp)) (parse (third sexp)))]
          [(app) ;; (app fun value)
           (app (parse (second sexp)) (parse (third sexp)))])])]
       [(list? (first sexp)) ;; faz o parsing de parenteses aninhados
        (parse (first sexp))]))

;; Tipo: CFAE/L
;; Representa a linguagem com Condicionais, Funções de primeira classe, laziness,
(define-type CFAE/L
  [num (n number?)]
  [add (lhs CFAE/L?) (rhs CFAE/L?)]
  [sub (lhs CFAE/L?) (rhs CFAE/L?)]
  [mul (lhs CFAE/L?) (rhs CFAE/L?)]
  [div (lhs CFAE/L?) (rhs CFAE/L?)]
  [id (name symbol?)]
  [fun (param symbol?) (body CFAE/L?)]
  [app (fun-expr CFAE/L?) (arg-expr CFAE/L?)])


;; boxed-boolean/CFAE/L-Value?: CFAE/L -> boolean
;; Verifica se um valor é um boxed-boolean/CFAE/L-Value
(define (boxed-boolean/CFAE/L-Value? v)
  (and (box? v)
       (or (boolean? (unbox v))
           (numV? (unbox v))
           (closureV (unbox v)))))


;; Tipo: CFAE/L-Value
;; Valores que o interpretador pode retornar.
(define-type CFAE/L-Value
  [numV (n number?)]
  [closureV (param symbol?)
            (body CFAE/L?)
            (env Env?)]
  [exprV (expr CFAE/L?)
         (env Env?)
         (cache boxed-boolean/CFAE/L-Value?)])


;; Tipo: Env
;; Um repositório de substituições deferidas.
(define-type Env
  [mtSub]
  [aSub (name symbol?)
        (value CFAE/L-Value?)
        (env Env?)])


;; num+: CFAE/L-Value, CFAE/L-Value -> numV
(define (num+ n1 n2)
  (numV (+ (numV-n (strict n1)) (numV-n (strict n2)))))


;; num-: CFAE/L-Value, CFAE/L-Value -> numV
(define (num- n1 n2)
  (numV (- (numV-n (strict n1)) (numV-n (strict n2)))))


;; num*: CFAE/L-Value, CFAE/L-Value -> numV
(define (num* n1 n2)
  (numV (* (numV-n (strict n1)) (numV-n (strict n2)))))


;; num/: CFAE/L-Value, CFAE/L-Value -> numV
(define (num/ n1 n2)
  (numV (/ (numV-n (strict n1)) (numV-n (strict n2)))))


;; num-zero?: CFAE/L-Value -> boolean
(define (num-zero? n)
  (zero? (numV-n (strict n))))


;; lookup: Symbol, Env -> CFAE/L
(define (lookup name env)
  (type-case Env env
             [mtSub () (error 'lookup "no binding for identifier")]
             [aSub (s-name s-value rest-env)
                   (if (symbol=? name s-name)
                       s-value
                       (lookup name rest-env))]))


;; strict: CFAE/L-Value -> CFAE/L-Value 
;; Força a interpretação de uma substituição deferida (até o final).
(define (strict e)
  (type-case CFAE/L-Value e
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


;; interp: CFAE/L, Env -> CFAE/L-Value
(define (interp expr env)
  (type-case CFAE/L expr
             [num (n) (numV n)]
             [add (lhs rhs) (num+ (interp lhs env) (interp rhs env))]
             [sub (lhs rhs) (num- (interp lhs env) (interp rhs env))]
             [mul (lhs rhs) (num* (interp lhs env) (interp rhs env))]
             [div (lhs rhs) (num/ (interp lhs env) (interp rhs env))]
             [id (name) (lookup name env)]
             [fun (param body)
                  (closureV param body env)]
             [app (fun-expr arg-expr)
                  (local ([define fun-val (strict (interp fun-expr env))]
                          [define arg-val (exprV arg-expr env (box false))])
                    (interp (closureV-body fun-val)
                            (aSub (closureV-param fun-val)
                                  arg-val
                                  (closureV-env fun-val))))]))


;; Testes
(test (interp (parse '{+ 2 2}) (mtSub)) (numV 4))
(test (interp (parse '{with {x {fun {x} {+ x x}}} {app x 10}} ) (mtSub)) (numV 20))
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