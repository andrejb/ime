;; The first three lines of this file were inserted by DrScheme. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "reader.ss" "plai" "lang")
;; <CFWAE> ::= <num>
;;     | {+ <CFWAE> <CFWAE>}
;;     | {- <CFWAE> <CFWAE>}
;;     | {* <CFWAE> <CFWAE>}
;;     | {/ <CFWAE> <CFWAE>}
;;     | <id>
;;     | {if0 <CFWAE> <CFWAE> <CFWAE>}
;;     | {with {{<id> <CFWAE>} ...} <CFWAE>}
;;     | {fun {<id> ...} <CFWAE>}
;;     | {<CFWAE> <CFWAE> ...}


;;-----------------------------------------------------------------------------
;; Tipos
;;-----------------------------------------------------------------------------

;; Binding : (symbol, CFWAE)
(define-type Binding
  [binding (name symbol?) (named-expr CFWAE?)])
 

;; CFWAE : estruturas da linguagem
(define-type CFWAE
  [num (n number?)]
  [id (name symbol?)]
  [with (lob (listof Binding?)) (body CFWAE?)]
  [if0 (c CFWAE?) (t CFWAE?) (e CFWAE?)]
  [fun (args (listof symbol?)) (body CFWAE?)]
  [binop (op procedure?) (lhs CFWAE?) (rhs CFWAE?)]
  [app (f CFWAE?) (args (listof CFWAE?))])


;; Env : um ambiente
(define-type Env
  [mtEnv]
  [anEnv (name symbol?) (value CFWAE-Value?) (env Env?)])


;; CFWAE-Value : tipos de retorno
(define-type CFWAE-Value
  [numV (n number?)]
  [closureV (params (listof symbol?))
            (body CFWAE?)
            (env Env?)])


;; um tipo para a tabela de operacoes binarias.
(define-type BinOpTable
  [mtOp]
  [anOp (name symbol?) (proc procedure?) (table BinOpTable?)])


;;-----------------------------------------------------------------------------
;; Parser
;;-----------------------------------------------------------------------------

;; parse : expression -> CFWAE
(define (parse exp)
  (cond
    [(number? exp) (num exp)]
    [(symbol? exp) (id exp)]
    [(list? exp) (match (first exp)
                   ['with
                    (with (parse-bindlist (second exp))
                          (parse (third exp)))]
                   ['if0
                    (if0 (parse (second exp))
                         (parse (third exp))
                         (parse (fourth exp)))]
                   ['fun
                    (fun (second exp) (parse (third exp)))]
                   [_
                    (case (first exp)
                      [(+ - * /)
                       (binop (first exp)
                              (parse (second exp))
                              (parse (third exp)))]
                      [else
                       (app (parse (first exp))
                            (parse-explist (rest exp)))])])]))


;; parse-withlist : (listof (symbol CFWAE)) ->  (listof Binding)
(define (parse-bindlist list)
  (if (empty? list)
      '()
      (cons (binding (first (first list)) (parse (second (first list))))
            (parse-bindlist (rest list)))))


;; parse-explist : (listof expression) ->  (listof CFWAE)
(define (parse-explist list)
  (if (empty? list)
      '()
      (cons (parse (first list)) (parse-bindlist (rest list)))))


;;-----------------------------------------------------------------------------
;; Interpreter
;;-----------------------------------------------------------------------------

;; binop-table : a tabela com as operacoes binarias.
(define (add-op name proc table)
  (set-box! table
            (anOp name proc (unbox table))))

(define binop-table (box (mtOp)))

(add-op '+ + binop-table)
(add-op '- - binop-table)
(add-op '* * binop-table)
(add-op '/ / binop-table)

(define (lookup-binop name table)
  (type-case BinOpTable table
             [mtOp ()
                   (error 'lookup-binop "no binary operation found with this name.")]
             [anOp (op-name op rest)
                   (if (symbol=? name op-name)
                       op
                       (lookup-binop name rest))]))


 ;; interp : CFWAE -> CFWAE-Value
(define (interp expr env)
   (type-case CFWAE expr
      [num (n) n]
      [id (v) (error 'interp "free identifier")]
      [with (bindings bound-body)
            (interp bound-body env)]
      [if0 (test t f) '()]
      [fun (args body) '()]
      [binop (op l r)
             ((lookup-binop op (unbox binop-table))
              (interp l env)
              (interp r env))]
      [app (f args) '()]))


;;-----------------------------------------------------------------------------
;; Testes
;;-----------------------------------------------------------------------------

;; Testes do livro levemente modificados, para a linguagem atual.
(test (interp (parse '5 ) (mtEnv)) (numV 5))
(test (interp (parse '{+ 5 5} ) (mtEnv)) (numV 10))
(test (interp (parse '{with {x {+ 5 5}} {+ x x}} ) (mtEnv)) (numV 20))
(test (interp (parse '{with {x 5} {+ x x}} ) (mtEnv)) (numV 10))
(test (interp (parse '{with {x {+ 5 5}} {with {y {- x 3}} {+ y y}}} ) (mtEnv)) (numV 14))
(test (interp (parse '{with {x 5} {with {y {- x 3}} {+ y y}}} ) (mtEnv)) (numV 4))
(test (interp (parse '{with {x 5} {+ x {with {x 3} 10}}} ) (mtEnv)) (numV 15))
(test (interp (parse '{with {x 5} {+ x {with {x 3} x}}} ) (mtEnv)) (numV 8))
(test (interp (parse '{with {x 5} {+ x {with {y 3} x}}} ) (mtEnv)) (numV 10))
(test (interp (parse '{with {x 5} {with {y x} y}} ) (mtEnv)) (numV 5))
(test (interp (parse '{with {x 5} {with {x x} x}} ) (mtEnv)) (numV 5))

;; Multi-armed with
(test (interp (parse '{with {{x 2} {y 3}} {with {{z {+ x y}}} {+ x z}}} )) 7)

;; Testes com funções
(test (interp (parse '{with {x {fun {x} {+ x x}}} {app x {10}}} ) (mtEnv)) (numV 20))
(test (interp (parse '{with {x {fun {x z} {+ x {* 2 z}}}} {app x {10 {+ 10 10}}}} ) (mtEnv)) (numV 50))
(test (interp (parse '{with {sum3 {fun {a b c} {+ a {+ b c}}}} {app sum3 {{+ 1 2} 4 {- 3 2}}}} ) (mtEnv)) (numV 8))
