# Autores:
# Darío de la Torre Guinaldo 
# Mario Garrido Tapias
.data
CadFecha1: .space 400
CadFecha2: .space 400
FechaResul: .space 400
Fecha1Sep: .space 100
Fecha2Sep: .space 100
FechaCachos1: .space 100
FechaCachos2: .space 100
CadDias: .space 20
CadHoras: .space 20
CadMinutos: .space 20
CadSegundos: .space 20
CadAñosNormales: .space 20
CadAñosBisiestos: .space 20
IntroducirFecha1: .asciiz "Introduzca la primera fecha: "
IntroducirFecha2: .asciiz "Introduzca la segunda fecha: "
FechaNoValidaCad: .asciiz "Fecha no válida.\n"
Fin1:.asciiz "Entre el "
Fin2: .asciiz " a las "
Fin3: .asciiz " y el "
Fin4: .asciiz " han pasado "
Fin5: .asciiz " años ordinarios, "
Fin6: .asciiz " bisiestos, "
Fin7: .asciiz " dias, "
Fin8: .asciiz " horas, "
Fin9: .asciiz " minutos y "
Fin10: .asciiz " segundos."

.text
main:
EntradaFecha1:
	la $a0, IntroducirFecha1	#Pide que se introduzca la primera fecha
	li $v0, 4
	syscall
	addi $a1, $a1, 100
	la $a0, CadFecha1
	li $v0, 8
	syscall
	jal LimpiarCadena
	la $a2, FechaCachos1
	la $a3, Fecha1Sep
	jal SepararFecha 		#Separa la primera fecha
	bne $v0, 0, ErrorFecha1
	la $a0, Fecha1Sep
	jal ValidarFecha
	beq $v0, 1, ErrorFecha1
EntradaFecha2:
	la $a0, IntroducirFecha2 	#Pide que se introduzca la segunda fecha
	li $v0, 4
	syscall
	addi $a1, $a1, 100
	la $a0, CadFecha2
	li $v0, 8
	syscall
	jal LimpiarCadena
	la $a2, FechaCachos2
	la $a3, Fecha2Sep
	jal SepararFecha 		#Separa la segunda fecha
	bne $v0, 0, ErrorFecha2	
	la $a0, Fecha2Sep
	beq $v0, 1, ErrorFecha2
	la $a2, Fecha1Sep
	la $a3, Fecha2Sep
	jal Comparacion
	addi $s0, $v0, 0
	beq $s0, 0, NoIntercambio	#Si es igual a 0 hay que hacer fecha1-fecha2, si no lo contrario
	la $s0, Fecha2Sep
	la $s1, Fecha1Sep
	j Diferencia
NoIntercambio:
	la $s0, Fecha1Sep
	la $s1, Fecha2Sep
Diferencia:
	la $s2, FechaResul
	addi $s0, $s0, 20		#Desplazamiento para buscar el campo segundos
	add $s1, $s1, 20
	addi $s7, $0, 0			#Contador de bucle
	addi $v0, $0, 0			#Reinicio del registro parámetro de la función siguiente para la primera iteración
MinSeg:	
	lw $a0, 0($s0)
	lw $a1, 0($s1)
	sub $a0, $a0, $v0		#Resta del acarreo
	jal DifMinSeg
	sw $v1, 0($s2)			#Almacena el resultado
	addi $s0, $s0, -4		#Decremento para buscar el siguiente campo
	addi $s1, $s1, -4
	addi $s2, $s2, 4		#Avanza a la siguiente posición en el vector de resultados
	addi $s7, $s7, 1
	bne $s7, 2, MinSeg
Horas:	
	addi $s0, $s0, -12
	addi $s1, $s1, -12
	lw $a0, 12($s0)	
	lw $a1, 12($s1)
	sub $a0, $a0, $v0		#Resta del acarreo
	jal DifHoras
	la $s2, FechaResul
	sw $v1, 8($s2)			#Almacena las horas
Dias:
	addi $a0, $s0, 0
	add $a1, $v0, $0		#Acarreo de las horas
	jal ToDias
	add $s4, $v0, $0
	addi $a0, $s1, 0
	addi $a1, $0, 0			#Acarreo de las horas(Siempre nulo, ya que lo tenemos en cuenta en Fecha1)
	jal ToDias
	add $s5, $v0, $0
	sub $s4, $s4, $s5	
Años:
	lw $a0, 8($s0)			#Cargar año Fecha mayor	
	jal BisiestosPas
	addi $s5, $v0, 0
	lw $a0, 8($s1)			#Cargar año Fecha menor
	jal BisiestosPas
	addi $s6, $v0, 0
	sub $s3, $s5, $s6 		#Hallar diferencia de años bisiestos pasados
	addi $t0, $0, 365
	div $s4, $t0			#Diferencia total de días/365
	mflo $s7			#El cociente son los años pasados
	mfhi $s4			#El resto son los días sueltos de diferencia
	sub $s4, $s4, $s3		#Se restan los días extras debido a la diferencia de bisiestos
	sub $s7, $s7, $s3		#Se restan los años bisiestos a los totales
	sw $s4, 12($s2)			#Guardar días
	sw $s7, 16($s2)			#Guardar años normales
	sw $s3, 20($s2)			#Guardar años bisiestos
Impresion:
	la $s2, FechaResul
	la $a0, Fin1
	li $v0, 4
	syscall
	la $a0, CadFecha1
	li $v0, 4
	syscall
	la $a0, Fin3
	li $v0, 4
	syscall
	la $a0, CadFecha2
	li $v0, 4
	syscall
	la $a0, Fin4
	li $v0, 4
	syscall
	lw $a2, 16($s2)			#Cargar años normales
	la $a0, CadAñosNormales
	jal BinToDec
	la $a0, CadAñosNormales
	li $v0, 4
	syscall
	la $a0, Fin5
	li $v0, 4
	syscall
	lw $a2, 20($s2)			#Cargar años bisiestos
	la $a0, CadAñosBisiestos
	jal BinToDec
	la $a0, CadAñosBisiestos
	li $v0, 4
	syscall
	la $a0, Fin6
	li $v0, 4
	syscall
	lw $a2, 12($s2)			#Cargar días
	la $a0, CadDias
	jal BinToDec
	la $a0, CadDias
	li $v0, 4
	syscall
	la $a0, Fin7
	li $v0, 4
	syscall
	lw $a2, 8($s2)			#Cargar horas
	la $a0, CadHoras
	jal BinToDec
	la $a0, CadHoras
	li $v0, 4
	syscall
	la $a0, Fin8
	li $v0, 4
	syscall
	lw $a2, 4($s2)			#Cargar minutos
	la $a0, CadMinutos
	jal BinToDec
	la $a0, CadMinutos
	li $v0, 4
	syscall
	la $a0, Fin9
	li $v0, 4
	syscall
	lw $a2, 0($s2)			#Cargar segundos
	la $a0, CadSegundos
	jal BinToDec
	la $a0, CadSegundos
	li $v0, 4
	syscall
	la $a0, Fin10
	li $v0, 4
	syscall
	li $v0, 10
	syscall
ErrorFecha1:
	la $a0, FechaNoValidaCad 
	li $v0, 4
	syscall
	la $a0, CadFecha1
	jal LimpiarDireccion		#Limpia la dirección para evitar errores
	la $a0, FechaCachos1
	jal LimpiarDireccion		#Limpia la dirección para evitar errores
	j EntradaFecha1
ErrorFecha2:
	la $a0, FechaNoValidaCad 
	li $v0, 4
	syscall
	la $a0, CadFecha2
	jal LimpiarDireccion		#Limpia la dirección para evitar errores
	la $a0, FechaCachos2
	jal LimpiarDireccion		#Limpia la dirección para evitar errores
	j EntradaFecha2
	
#Intercambia el caracter retorno de linea "\n" por "\0" como fin de cadena
#Parámetros -> $a0: Dirección del String a limpiar
LimpiarCadena:				#Limpia la cadena
	addi $t6, $0, 0			#Contador para controlar la longitud de la cadena introducida
BucleLimpiarCadena:
	lb $t1, 0($a0)
	addi $a0, $a0, 1
	addi $t6, $t6, 1
	bne $t1, 10, BucleLimpiarCadena
	sb $0, -1($a0)			#Sustituimos fin de linea --> fin de cadena
	sub $a0, $a0, $t6		#Volvemos al principio de la cadena
	jr $ra

#Pone a 0 todos los bytes de memoria de una direccion dada
#Parámetros -> $a0: Dirección de memoria a limpiar
LimpiarDireccion:
	addi $t6, $0, 0
BucleLimpiarDireccion:
	sb $t6, 0($a0)
	lb $t1, 1($a0)				#Carga el siguiente byte para comparar después
	addi $a0, $a0, 1
	bne $t1, $0, BucleLimpiarDireccion	#Si encuentra el carácter \0 en el siguinete byte sale del bucle
	jr $ra	 
	
#Coge cada fragmento utilizando como indicativo los separadores y los introduce un array 
#Parámetros -> $a0: Dirección del String leido, ya limpio. 
#		$a2: Dirección del vector en el que hará los cálculos. 
#		$a3: Array donde meterá los números
#Return -> $v0: Código de error: 0 si la fecha es válida, 1 si la fecha no es válida.
SepararFecha:
	addi $sp, $sp, -16		#Reserva de espacio en la pila
	add $s0, $a0, $0		#Dirección del String original
	add $s1, $a2, $0		#Array de fragmentos de cadenas
	add $s2, $a3, $0		#Array de enteros 
	sw $ra, 0($sp)
	addi $t7, $0, 0			#Contador de número de separadores
	addi $t4, $0, 0			#Contador de número de iteraciones por busqueda de campo
Recorrer:				#Bucle para los distintos separadores "/"," ",":",...				
	lb $t1, 0($s0)		
	addi $s0, $s0, 1
	lb $t3, 0($s0)			#Carga del siguiente para comparar si fuese ya el separador
	sb $t1, 0($s1)
	addi $s1, $s1, 1
	addi $t4, $t4, 1
	beq $t3, 32, Separacion		#Espacio
	beq $t3, 45, Separacion		#"-"
	beq $t3, 47, Separacion		#"/"
	beq $t3, 58, Separacion		#":"
	beq $t3, 0, Separacion		#"\0"
	j Recorrer
Separacion:
	addi $t7, $t7, 1
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sub $a2, $s1, $t4		#Vuelta del registro a la posición inicial del campo
	jal DecToBin
	bne $v0, 0, FechaNoValida	
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	sw $v1, 0($s2)			#Almacenamiento del campo fraccionado
	addi $s2, $s2, 4
	addi $s0, $s0, 1
	addi $t4, $0, 0			#Reinicio contador de número de iteraciones por busqueda
	bne $t7, 6, Recorrer
Final:
	sw $v1, 0($s2)			#Almacenamiento del último campo (segundos)					
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16		#Devolvemos a la pila el espacio
	addi $v0, $0, 0			#Fecha válida
	addi $t4, $0, 0			#Reinicio contador de número de iteraciones por busqueda
	jr $ra
FechaNoValida:
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	addi $v0, $0, 1			#Fecha no válida
	jr $ra
	
#Convierte de Decimal a Binario
#Parámetros -> $a2: Dirección del String a convertir
#Return -> 	$v0: Código de Error 
#		$v1: Valor transformado
DecToBin:
	addi $t3, $0, 0			#Reinicio para que no almacene en caso de entradas incorrectas
	addi $t9, $0, 0	
	addi $v0, $0, 0
	add $t0, $a2, $0
	addi $t8, $0, 10		#Constante de multiplicación, base 10
	lb $t1, 0($t0)
	bne $t1, 45, NoNegativo		#Comprueba si hay un signo negativo en el primer caracter
	addi $t9, $0, 1			#Si es negativo guarda un 1 en $t9
	j SaltoSig
Bucle:	
	lb $t1, 0($t0)
NoNegativo:	
	addi $t1, $t1, -48
	blt $t1, $0, ECaracErr		#Intervalo ASCII [0,47]
	bge $t1, 10, ECaracErr		#Intervalo ASCII [59,FinASCII]
	addu $t3, $t3, $t1		#Suma sin tener en cuenta el posible OVERFLOW
	blt $t3, $0, ECadLarga		#Si ha habido desbordamiento salta el error
SaltoSig:
	lb $t2, 1($t0)
	addi $t0, $t0, 1
	beq $t2, $0, Fin
	mul $t3, $t3, $t8
	mfhi $t5 			#Movemos el contenido de HI para comprobar si es distinto de 0, lo que indica OVEFLOW
	bne $t5, $0, ECadLarga
	j Bucle
Fin: 
	bne $t9, 1, NoComplemento	#Si tenia un signo - complementa el numero
	sub $t3, $0, $t3		#0 - Número resultante para pasarlo a negativo
NoComplemento:
	addi $v1, $t3, 0
	jr $ra
ECaracErr:
	addi $v0, $0, 1			#Codigo de error 2
	jr $ra
ECadLarga:
	addi $v0, $0, 2			#Codigo de error 1
	jr $ra	

#Analiza si una fecha es válida.
#Parámetros -> $a0: La dirección del vector donde se encuentran ya separados cada parte de la fecha
#Return -> $v0: 0 si la fecha es válida, 1 si la fecha no es válida.
ValidarFecha:
	addi $t9, $a0, 0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $a0, 8($t9) 			#Carga el año
	jal ValidarAño 
	beq $v0, 1, ErrorFecha
	move $a1, $v1			#Copia el parámetro para saber si es bisiesto
	lw $a0, 4($t9) 			#Carga el mes
	jal ValidarMes
	beq $v0, 1, ErrorFecha
	move $a1, $v1			#Copia el parámetro para saber cuántos días tiene el mes
	lw $a0, 0($t9) 			#Carga el dia
	jal ValidarDia
	beq $v0, 1, ErrorFecha
	lw $a0, 12($t9) 		#Carga la hora
	jal ValidarHora
	beq $v0, 1, ErrorFecha
	lw $a0, 16($t9) 		#Carga el minuto
	jal ValidarMinutoSegundo
	beq $v0, 1, ErrorFecha
	lw $a0, 20($t9)			#Carga el segundo
	jal ValidarMinutoSegundo
	beq $v0, 1, ErrorFecha
	addi $v0, $0, 0			#No ha habido error en ninguna parte de la fecha
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra 
ErrorFecha:
	addi $v0, $0, 1			#Ha habido error en alguna parte de la fecha
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#Analiza si un año dado es válido, y si lo es, halla si es bisiesto o no.
#Un año es bisiesto si es divisible entre 4 pero no entre 100 o si es divisible entre 400.
#Parámetros -> $a0: Número que representa el año.
#Return -> 	$v0: 0 si es válido, 1 si no es válido. 
#		$v1: 0 si no es bisiesto, 1 si es bisiesto.
ValidarAño:
	addi $t0, $a0, 0
	addi $t3, $0, 400
	blt $t0, 1, ErrorAño 		#Si el año es 0 o negativo entonces es erróneo
	div $t0, $t3			#Divide entre 400
	mfhi $t4
	addi $t3, $0, 4
	beq $t4, 0, AñoBisiesto		#Si es divisible entre 400 entonces es bisiesto
	div $t0, $t3			#Divide entre 4
	mfhi $t4
	addi $t3, $0, 100
	bne $t4, 0, AñoNoBisiesto	#Si no es divisible entre 4 entonces no es bisiesto
	div $t0, $t3			#Divide entre 100
	mfhi $t4
	beq $t4, 0, AñoNoBisiesto	#Si es divisible entre 4 y entre 100 entonces no es bisiesto
	j AñoBisiesto			#Si es divisible entre 4 pero no entre 100 entonces es bisiesto
AñoNoBisiesto:
	addi $v0, $0, 0
	addi $v1, $0, 0
	jr $ra	
AñoBisiesto:
	addi $v0, $0, 0
	addi $v1, $0, 1
	jr $ra
ErrorAño:
	addi $v0, $0, 1
	jr $ra
	
#Analiza si un mes dado es válido.
#Parámetros -> 	$a0: Número que representa el mes
#		$a1: 0 si no es año bisiesto, 1 si es año bisiesto
#Return -> 	$v0: 0 si es válido, 1 si no es válido. 
#		$v1: El número de días del mes.
ValidarMes:
	addi $t0, $a0, 0
	addi $t1, $a1, 0
	blt $t0, 1, ErrorMes	#Si es menor que 1 o mayor que 12 entonces es erróneo
	bgt $t0, 12, ErrorMes
	#SWITCH
	beq $t0, 1, MesDe31
	beq $t0, 2, Febrero
	beq $t0, 3, MesDe31
	beq $t0, 4, MesDe30
	beq $t0, 5, MesDe31
	beq $t0, 6, MesDe30
	beq $t0, 7, MesDe31
	beq $t0, 8, MesDe31
	beq $t0, 9, MesDe30
	beq $t0, 10, MesDe31
	beq $t0, 11, MesDe30
	beq $t0, 12, MesDe31
MesDe30:
	addi $v1, $0, 30
	j SinErrorMes
MesDe31:
	addi $v1, $0, 31
	j SinErrorMes
Febrero:
	beq $t1, 1, FebreroBisiesto
	addi $v1, $0, 28
	j SinErrorMes
FebreroBisiesto:
	addi $v1, $0, 29
	j SinErrorMes
SinErrorMes:
	addi $v0, $0, 0
	jr $ra
ErrorMes:
	addi $v0, $0, 1
	jr $ra
	
#Analiza si un día dado es válido.
#Parámetros -> 	$a0: Número que representa el día del mes. 
#		$a1: Número de días que tiene el mes al que pertenece ese día.
#Return -> $v0: 0 si es válido, 1 si no es válido.
ValidarDia:
	addi $t0, $a0, 0
	addi $t1, $a1, 0
	blt $t0, 1, ErrorDia	#Si es menor que 1 o mayor que el número de días del mes entonces es erróneo
	bgt $t0, $t1, ErrorDia
	addi $v0, $0, 0
	jr $ra
ErrorDia:
	addi $v0, $0, 1
	jr $ra

#Analiza si una hora es válida.
#Parámetros -> $a0: Número que representa la hora.
#Return -> $v0: 0 si es válida, 1 si no es válida.
ValidarHora:
	addi $t0, $a0, 0
	blt $t0, 0, ErrorHora	#Si es menor que 0 o mayor que 23 entonces es errónea
	bgt $t0, 23, ErrorHora  
	addi $v0, $0, 0 
	jr $ra
ErrorHora:
	addi $v0, $0, 1
	jr $ra
	
#Analiza si un minuto o un segundo es válido.
#Parámetros -> $a0: Número que representa el minuto o el segundo.
#Return -> 0 si es válido, 1 si no es válido.
ValidarMinutoSegundo:
	addi $t0, $a0, 0
	blt $t0, 0, ErrorMinutoSegundo #Si es menor que 0 o mayor que 59 entonces es erróneo
	bgt $t0, 59, ErrorMinutoSegundo
	addi $v0, $0, 0
	jr $ra
ErrorMinutoSegundo:
	addi $v0, $0, 1
	jr $ra
	
#Calcula la diferencia que existe entre los campos minuto y segundo
#Parametros 	-> $a0: Primera Fecha (campo correspondiente)
#		-> $a1: Segunda Fecha (campo correspondiente)
#Return		-> $v0: acarreo de la operación
#		-> $v1: resultado de la operación
DifMinSeg:
	add $t0, $a0, $0
	add $t1, $a1, $0
	sub $t2, $t0, $t1
	bge $t2, 0, SinAcarreoMinSeg	#Si el resultado es positivo es correcto
	add $t0, $t0, 60		#Si el resultado es negativo se le suma 60 para poder restar
	sub $t2, $t0, $t1	
	addi $v0, $0, 1
	addi $v1, $t2, 0
	jr $ra
SinAcarreoMinSeg:
	addi $v0, $0, 0
	addi $v1, $t2, 0
	jr $ra
	
#Calcula la diferencia que existe entre los campos hora.
#Parametros 	-> $a0: Primera Fecha (campo HORA)
#		-> $a1: Segunda Fecha (campo HORA)
#Return		-> $v0: acarreo de la operación
#		-> $v1: resultado de la operación	
DifHoras:
	add $t0, $a0, $0
	add $t1, $a1, $0
	sub $t2, $t0, $t1
	bge $t2, 0, SinAcarreoHor	#Si el resultado es poitivo es correcto
	add $t0, $t0, 24		#Si el resultado es negativo se le suma 24 para poder restar
	sub $t2, $t0, $t1	
	addi $v0, $0, 1
	addi $v1, $t2, 0
	jr $ra
SinAcarreoHor:
	addi $v0, $0, 0
	addi $v1, $t2, 0
	jr $ra

#Transforma años, meses y dias de una fecha en días
#Parámetros 	-> $a0: Vector de enteros correspondiente a las partes de la fecha
#		-> $a1: Acarreo el campo anterior(HORA)
#Return		-> $v0: Números de días 
ToDias:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a1, 4($sp)
	addi $a1, $0, 0			#Reset
	addi $t4, $0, 0
	add $t9, $a0, $0
	addi $t7, $0, 365		#Constante para multiplicar
	lw $t1, 8($t9)			#Carga del campo AÑO
	add $a0, $t1, $0
	jal ValidarAño			#Para comprobar si es bisiesto
	mul $t2, $t1, $t7		#Numero de años * 365 (Resultado de la multiplicación --> $t2)
	add $t7, $v1, 0
	add $a0, $t1, $0	 	#Almacenamos en un registro si es el año es bisiesto o no
	jal BisiestosPas
	add $t4, $0, 0			#Reinicio del registro
	add $t3, $v0, $0		#Pasamos el resultado de la función
	add $t2, $t2, $t3		#Total de dias pasados teniendo en cuenta años bisiestos
	lw $t3, 0($t9)			#Carga del campo DIAS para restar el acarreo
	lw $t5, 4($sp)
	sub $t3, $t3, $t5		#Resta del acarreo
	sw $t3, 0($t9)
	addi $t5, $0, 0			#Reset
	addi $t8, $0, 0			#Contador de meses pasados
	lw $t3, 4($t9)			#Carga del campo MES
	beq $t3, 1, Enero
	addi $t8, $0, 1
BucleMes:
	addi $a0, $t8, 0
	bne $t7, 1, NoBisiesto 
	addi $a1, $0, 1
NoBisiesto:
	jal ValidarMes			#La función me devuelve el numero de dias de ese mes
	add $t4, $t4, $v1		#Acumulador de dias pasados en los meses transcurridos
	addi $t8, $t8, 1
	bne $t8, $t3, BucleMes
Enero:
	lw $t3, 0($t9)			#Carga del campo DIAS
	add $t2, $t2, $t4		#Suma dias (AÑOS) + dias (MES)
	add $t3, $t3, $t2		#Suma anterior + dias
	addi $v0, $t3, 0
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra	
	
#Calcula el número de años bisiestos pasados.
#Parámetros	-> $a0: Año correspondiente 
#Return		-> $v0: Número de años bisiestos pasados 
BisiestosPas:
	add $t1, $a0, $0
	addi $t6, $0, 4			#Constante para dividir
	div $t1, $t6			#Numero de año/4
	mflo $t5
	addi $t6, $0, 100		#Constante para dividir
	div $t1, $t6			#Numero de año/100
	mflo $t6
	sub $t5, $t5, $t6
	addi $t6, $0, 400		#Constante para dividir
	div $t1, $t6			#Numero de año/400
	mflo $t6
	add $t5, $t5, $t6
	add $v0, $t5, $0
	jr $ra

#Convierte de Binario a Decimal
#Parámetros -> 	$a0: Dirección donde se guardara el numero convertido.
#		$a2: Numero entero a convertir.
BinToDec:
	add $t0, $a2, $0		#Carga el número entero
	add $t1, $a0, $0		#Carga la dirección donde se guardará la cadena
	addi $t8, $0, 10		#Constante de división
	slti $t9, $t0, 0 		#Si es negativo guardamos un 1 en $t9, en caso contrario un 0
	bne $t9, 1, BucleBNToDEC
	sub $t0, $0, $t0		#Convierte el número en positivo para operar
BucleBNToDEC:
	div $t0, $t8			
	mfhi $t3			#Movemos el RESTO
	addi $t5, $t3, 48
	sb $t5, 0($t1)			#Guardamos el resto en la direccion ya transformado a ASCII
	mflo $t0			#Movemos el COCIENTE
	addi $t1, $t1, 1
	bne $t0, 0, BucleBNToDEC
	bne $t9, 1, InvertirCad
	addi $t8, $0, 45		#Valor del carácter -
	sb $t8, 0($t1)
InvertirCad:
	add $t2, $0, 0			#Reinicios
	add $t0, $0, 0
	add $t3, $0, 0
	add $t1, $0, 0
	add $t1, $a0, $0		#Paso a temporales
	add $t4, $a0, $0
BucleRecorrer:				#Recorremos la copia de la dirección hasta encontrar un 0 
	lb $t0, 0($t1)
	addi $t1, $t1, 1
	bne $t0, 0, BucleRecorrer
	addi $t1, $t1, -2		#Corregimos para igualar direcciones
BucleInvert:				#Cargando y guardando intercambiando elementos
	lb $t2, 0($t4)			
	lb $t3, 0($t1)
	sb $t3, 0($t4)
	sb $t2, 0($t1)
	add $t4, $t4, 1
	add $t1, $t1, -1
	beq $t1, $t4, Salida
	blt $t1, $t4, Salida
	j BucleInvert
Salida:
	jr $ra	

#Compara las fechas para saber cuál es mayor
#Parámetros -> $a2: Vector de enteros correspondiente a las partes de la fecha 1
#	       $a3: Vector de enteros correspondiente a las partes de la fecha 2
#Return     -> $v0: 0 si la fecha 1 es mayor que la fecha 2 o si son iguales,
#		    1 si la fecha 2 es mayor que la fecha 1
Comparacion:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $a1, $0, 0
	addi $a0, $a2, 0
	jal ToDias
	addi $sp, $sp, -4
	sw $v0, 0($sp)
	addi $a0, $a3, 0
	addi $a1, $0, 0
	jal ToDias
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	sub $t0, $t0, $v0 		#Diferencia de días totales
	blt $t0, 0, fech2mayorquefech1	#Si la diferencia es negativa
	bgt $t0, 0, fech1mayorquefech2	#Si la diferencia es positivo
	#Si son iguales hay que comparar los siguientes campos
	lw $t0, 12($a2)
	lw $t1, 12($a3)
	sub $t0, $t0, $t1		#Diferencia de horas
	blt $t0, 0, fech2mayorquefech1	#Si la diferencia es negativa
	bgt $t0, 0, fech1mayorquefech2	#Si la diferencia es positivo
	lw $t0, 16($a2)
	lw $t1, 16($a3)
	sub $t0, $t0, $t1		#Diferencia de minutos
	blt $t0, 0, fech2mayorquefech1	#Si la diferencia es negativa
	bgt $t0, 0, fech1mayorquefech2	#Si la diferencia es positivo
	lw $t0, 12($a2)
	lw $t1, 12($a3)
	sub $t0, $t0, $t1		#Diferencia de segundos
	blt $t0, 0, fech2mayorquefech1	#Si la diferencia es negativa
	bge $t0, 0, fech1mayorquefech2	#Si la diferencia es positivo
fech1mayorquefech2:
	addi $v0, $0, 0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra 
fech2mayorquefech1:
	addi $v0, $0, 1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
