;; The first three lines of this file were inserted by DrScheme. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "reader.ss" "plai" "lang")
;;  Scheme Tutorial Exercises
;;  =========================
;;
;;  Fall 2003
;;  Problem Set 1: Basic Scheme
;;
;;  1. The local supermarket needs a program that can compute the value of a bag of
;;     coins. Define the program sum-coins. It consumes four numbers: the number
;;     of pennies, nickels, dimes, and quarters in the bag; it produces the amount of
;;     money in the bag. (HtDP Exercise 2.3.2)

(define coins-to-dollars
  (lambda (v)
    (lambda (c)
      (* v c))))

(define pennies-to-dollars
  (coins-to-dollars (/ 1.0 100)))

(define nickels-to-dollars
  (coins-to-dollars (/ 5.0 100)))

(define dimes-to-dollars
  (coins-to-dollars (/ 10.0 100)))

(define quarters-to-dollars
  (coins-to-dollars (/ 25.0 100)))

(define sum-coins
  (lambda (p n d q)
    (+ (+ (+
           (pennies-to-dollars p)
           (nickels-to-dollars n))
          (dimes-to-dollars d))
       (quarters-to-dollars q))))

;; Testes
(display "Exercicio 1:\n")
(test (sum-coins 1 0 0 0) 0.01)
(test (sum-coins 0 1 0 0) 0.05)
(test (sum-coins 0 0 1 0) 0.1)
(test (sum-coins 0 0 0 1) 0.25)
(test (sum-coins 2 0 0 0) 0.02)
(test (sum-coins 0 3 0 0) 0.15)
(test (sum-coins 0 0 4 0) 0.4)
(test (sum-coins 0 0 0 5) 1.25)
(test (sum-coins 10 2 3 4) 1.50)


;;  2. Develop area-cylinder. The program consumes the radius of the cylinder's
;;     base disk and its height. Its result is the surface area of the cylinder.
;;     (Exercise 3.3.3)

(define PI 3.14159)

(define area-disk
  (lambda (r)
    (* (PI (* r r)))))

(define circumpherence-disk
  (lambda (r)
    (* 2 (* PI r))))

(define area-cylinder
  (lambda (r h)
    (+ (* 2 (area-disk r))
       (area-rectangle (circumpherence-disk r) h))))


;;  3. Develop the function area-pipe. It computes the surface area of a pipe,
;;     which is an open cylinder. The program consumes three values: the pipe's
;;     inner radius, its length, and the thickness of its wall. (HtDP Exercise
;;     3.3.4)

(define (area-ring outer inner) 
  (- (area-disk outer)
     (area-disk inner)))

(define area-pipe
  (lambda (r l t)
    (+ (* 2 (area-ring (+ r t) r))
       (+ (area-rectangle (circumpherence-disk r) l)
          (area-rectangle (circumpherence-disk (+ r t) l))))))


;;     Develop two versions: a program that consists of a single definition and a pro-
;;     gram that consists of several function definitions. Which one evokes more con-
;;     fidence?
;;
;;  4. Develop the function tax, which consumes the gross pay and produces the amount
;;     of tax owed. For a gross pay of $240 or less, the tax is 0%; for over $240 and
;;     $480 or less, the tax rate is 15%; and for any pay over $480, the tax rate is
;;     28%. (HtDP Exercise 4.4.2)
;;
;;     Also develop netpay. The function determines the net pay of an employee from
;;     the number of hours worked. The net pay is the gross pay minus the tax. Assume
;;     the hourly pay rate is $12.
;;
;;     Hint: Remember to develop auxiliary functions when a definition becomes too
;;     large or too complex to manage.
;;
;;  5. Develop what-kind. The function consumes the coefficients a, b, and c of
;;     a quadratic equation. It then determines whether the equation is
;;     degenerate and, if not, how many solutions the equation has. The
;;     function produces one of four symbols: 'degenerate, 'two, 'one, or
;;     'none. An equation is degenerate if a = 0. (HtDP Exercise 5.1.4)
;;
;;  6. Provide a datatype definition for representing points in time since midnight. A
;;     point in time consists of three numbers: hours, minutes, and seconds. (HtDP
;;     Exercise 6.4.2)
;;
;;     Now develop the function time-diff . It consumes two time structures, t1
;;     and t2, and returns the number of seconds from t1 to t2. For example:
;;
;;     (time-diff (time-point 1 2 3) (time-point 4 5 6))
;;     >10983
;;
;;  7. Provide a datatype definition for a position, which is a two-dimensional
;;     location.
;;     Next, provide a datatype definition for shapes. There are three kinds of
;;     shapes:
;;       - a circle has a center (position) and a radius (number)
;;       - a square has an upper-left corner (position) and a length (number)
;;       - rectangle has an upper-left corner (position), width (number), and height
;;         (number)
;;
;;  8. Develop the function area, which consumes a shape and computes its area.
;;     (HtDP Exercise 7.1.3)
;;
;;  9. Develop translate-shape. The function consumes a shape and a number delta,
;;     and produces a shape whose key position is moved by delta pixels in the 
;;     xdirection. (HtDP Exercise 7.4.3)
;;
;;  10. Develop the function in-shape?, which consumes a shape and a position
;;      p, and returns true if p is within the shape, false otherwise.
