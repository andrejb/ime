;; The first three lines of this file were inserted by DrScheme. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "reader.ss" "plai" "lang")
;; WAE: linguagem com expressoes aritmeticas e substituicao.
;; Exercicio 1


;; tipo WAE
(define-type WAE
  [num (n number?)]
  [with (assocs AssocList?) (body WAE?)]
  [id (name symbol?)]
  [binop (op symbol?) (lhs WAE?) (rhs WAE?)])


;; um tipo para a tabela de operacoes binarias.
(define-type BinOpTable
  [mtOp]
  [anOp (name symbol?) (proc procedure?) (table BinOpTable?)])


;; um tipo para a lista de associações
(define-type AssocList
  [mtAssocList]
  [anAssoc (id symbol?) (expr WAE?) (list AssocList?)])


;; parse-withlist: sexp -> AssocList
(define (parse-withlist sexp parsed-list)
  (if (empty? sexp)
      parsed-list
      (if (bound-name? (first (first sexp)) parsed-list)
          (error 'parse-withlist "there is another binding with the same name.")
          (parse-withlist (rest sexp)
                          (anAssoc (first (first sexp))
                                   (parse (second (first sexp)))
                                   parsed-list)))))

;; parse : sexp -> WAE
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(symbol? sexp) (id sexp)]
    [(list? sexp)
     (case (first sexp)
       [(with) (with (parse-withlist (second sexp) (mtAssocList))
                     (parse (third sexp)))]
       [else (binop (first sexp)
                    (parse (second sexp))
                    (parse (third sexp)))])]))

;; bound-name? symbol AssocList -> boolean
(define (bound-name? name list)
  (type-case AssocList list
             [mtAssocList () false]
             [anAssoc (id expr assoc-list)
              (if (symbol=? name id)
                  't
                  (bound-name? name assoc-list))]))


;; subst : WAE AssocList -> WAE
(define (subst expr assocs)
  (type-case AssocList assocs
             [mtAssocList () expr]
             [anAssoc (assoc-id assoc-expr assoc-list)
              (if (bound-name? assoc-id assoc-list)
                  (error 'subst-expr "there is another binding with the same name.")
                  (subst
                   (subst-assoc expr
                                assoc-id
                                (num (interp assoc-expr)))
                   assoc-list))]))


;; subst-assoc: WAY symbol WAE -> WAE
(define (subst-assoc expr sub-id val)
  (type-case WAE expr
             [num (n) expr]
             [binop (op l r) (binop op
                                    (subst-assoc l sub-id val)
                                    (subst-assoc r sub-id val))]
             [with (assoc-list bound-body)
                   (with (subst-assoc-list assoc-list sub-id val)
                         (if (bound-name? sub-id assoc-list)
                             bound-body
                             (subst-assoc bound-body sub-id val)))]                   
             [id (v) (if (symbol=? v sub-id) val expr)]))


;; subst-assoc-list AssocList symbol WAE -> AssocList
(define (subst-assoc-list list id val)
  (type-case AssocList list
             [mtAssocList () (mtAssocList)]
             [anAssoc (assoc-id assoc-expr assoc-list)
                      (anAssoc assoc-id
                               (subst-assoc assoc-expr id val)
                               (subst-assoc-list assoc-list id val))]))


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

;; interp : WAE -> number
(define (interp expr)
   (type-case WAE expr
      [num (n) n]
      [binop (op l r)
             ((lookup-binop op (unbox binop-table))
              (interp l)
              (interp r))]
      [with (assocs bound-body)
             (interp (subst bound-body
                            assocs))]
      [id (v) (error 'interp "free identifier")]))


(parse '{with {{t 3}} t} )
(interp (parse '{with {{t 3}} t} ))
(parse '{with {{t 3}} {with {{u 4}} {+ t u}}} )
(interp (parse '{with {{t 3}} {with {{u 4}} {+ t u}}} ))


;;-----------------------------------------------------------------------------
;; Testes
;;-----------------------------------------------------------------------------

(test (interp (parse '5 )) 5)
(test (interp (parse '{+ 5 5} )) 10)
(test (interp (parse '{with {{x {+ 5 5}}} {+ x x}} ) ) 20)
(test (interp (parse '{with {{x 5}} {+ x x}} ) ) 10)
(test (interp (parse '{with {{x {+ 5 5}}} {with {{y {- x 3}}} {+ y y}}} ) ) 14)
(test (interp (parse '{with {{x 5}} {with {{y {- x 3}}} {+ y y}}} ) ) 4)
(test (interp (parse '{with {{x 5}} {+ x {with {{x 3}} 10}}} ) ) 15)
(test (interp (parse '{with {{x 5}} {+ x {with {{x 3}} x}}} ) ) 8)
(test (interp (parse '{with {{x 5}} {+ x {with {{y 3}} x}}} ) ) 10)
(test (interp (parse '{with {{x 5}} {with {{y x}} y}} ) ) 5)
(test (interp (parse '{with {{x 5}} {with {{x x}} x}} ) ) 5)

;; Multi-armed with
(test (interp (parse '{with {{x 2} {y 3}} {with {{z {+ x y}}} {+ x z}}} )) 7)
