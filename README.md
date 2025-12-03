# Proyecto II: Diseño digital en HDL
### Jiahui Zhong Xie
### Ximena Araya Brenes 
## 1. Introducción
El proyecto consiste en la implementación del diseño sincrónico a través de una FPGA (Field Programmable Gate Array), en este caso la Tang Nano 9k, y HDL (Hardware Description Language) SystemVerilog. El sistema diseñado se trata de un teclado hexadecimal que recibe dos números enteros positivos de tres dígitos como máximo cada uno, los cuales se dividen de manera interna y cuyo resultado es desplegado en un display de 7 segmentos. Además, este mismo al estar compuesto por cociente y por residuo, son desplegados en orden, mediante el uso de un botón. Para este proyecto, se implementaron varios principios del diseño digital, como lo es la eliminación de rebotes (debouncer), el uso de una máquina de estados finitos (FSM), conversión de binario a BCD, entre otros. 
## 2. Objetivos
El problema principal por resolver es la implementación tanto física como lógica de un divisor simple de tres dígitos, mediante un teclado hezadecimal y un display de 7 segmentos, así como botones que permitan desplegar tanto el cociente como el residuo, el cual opera a la frecuencia de reloj de la FPGA (27MHz). 
El objetivo principal es el desarrollo de un sistema digital utilizando Hardware Description Language, en este caso, la implementación de algoritmos por medio de máquinas de estado complejas. Los objetivos específicos consisten en implementar diseño digital en una FPGA, construir un testbench que permita comprobar las especificaciones requeridas, implementar un algoritmo de división de enteros con una máquina de estados finitos. Así como, trabajar en la coordinación de trabajo en equipo y planificar tareas para trabajos. 
## 3. Funcionamiento del circuito y subsistemas
El circuito de manera general, consiste en un teclado hexadecimal, un display de 7 segmentos de 4 dígitos de cátodo común, así como de elementos resistivos y transistores BJT de tipo NPN. En primer lugar, el teclado hexadecimal se encuentra conectado directamente a los pines de la FPGA, a excepción de las filas, las cuales cuentan con una resistencia de regulación. Posteriormente, el display se encuentra conectado a una resistencia que proteje a la FPGA antes de los pines, además, los pines encargados de controlar la activación de cada dígito son regulados a manera de "switch" mediante un transistor BJT. Finalmente, para este diseño se implementaron botones que permiten realizar operaciones a través de la FPGA. La lógica consiste en el escaneo del teclado matricial para determinar qué tecla fue presionar, es decir, el usuario puede ingresar un dividendo y un divisor, luego se realiza la división de manera iterativa, se convierte el resultado a BCD y el resultado, tanto cociente como residuo. 
### 3.1 Subsistema de lectura del teclado mecánico hexadecimal
Primero se realiza un "barrido" de las columnas y filas para determinar que teclas fueron presionadas, luego el debouncer se encarga de verificar que no se generen rebotes, es decir, que los pulsos sean correctos y finalmente, convierte las convierte a señales lógicas. En este caso, se controla mediante una FSM en el momento en el que los dígitos son ingresados, tanto del dividendo y el divisor. Las saildas de este subsistema consisten en: dividendo, divisor y start_division. 
### 3.2 Subsistema de división iterativa de los datos
En este subsistema se ejecuta la lógica iterativa de división, es decir, se reciben tanto el dividendo como el divisor, se realiza la división N cantidad de iteraciones. Lo cual produce el residuo y el cociente, finalmente, ejecuta los ciclos para realizar la resta, se registra el residuo y se desplaza. El funcionamiento del algoritmo se muestra en la imagen a continuación: 

![Algoritmo de división iterativo](ima/algoritmo.png)

### 3.3 Subsistema de conversión binaria a BCD 
Este último se encarga de recibir los datos en formato BCD y mostrarlos en el display de 7 segmentos, para ello, en el primer módulo se indica que número debe mostrarse, luego se decodifica para poder ser representado en los siete segmentos (a-g) de manera correspondiente, por último el multiplexor se encarga de activar un display a la vez. 
### 3.4 Subsistema de despliegue de 7 segmentos 
Su función principal, como su nombre lo indica, es mostrar los resultados obtenidos en el display de 7 segmentos, para ello, se utiliza el refresh, lo cual permite reiniciar la operación. Se activan los dígitos de acuerdo al funcionamiento de la conversión de BCD a 7 segmentos. 

## 4. Diagrama de bloques 
En la siguiente imagen, se encuentra el diagrama de bloques: 
![Diagrama de bloques](ima/diagramabloques.png)
### 4.1 Teclado hexadecimal y keypad_scanner 
Este módulo se encarga de la lectura del teclado matricial, recibe la señal de reloj y de las filas y columnas presionadas, para luego realizar un barrido y con ello, detectar cuáles teclas estpan activas. 
### 4.2 Debouncer
Este se encarga de garantizar que la señal sea estable, es decir, que no se repita y que sea leída correctamente. 
### 4.3 Key_deco o decodificador de teclas 
Este módulo realiza la "traducción" del código del teclado e indica si lo presionado fue un número. 
### 4.4 Control de FSM (botones)
Se asegura que cada botón no genere rebotes y se controla de manera general el flujo del sistemas. Además, se registra el primer operando, es decir el dividendo, y luego el divisor. El primer dígito se guarda en 4 bits y cada dígito desplaza el número 4 bits a la izquierda. 
### 4.5 Division unit 
Opera de manera interna con un total de 16 bits, implementa el algoritmo iterativo de división por resta y desplazamiento, es decir, realiza la operación matemática como tal. 
### 4.6 Control de FSM (resultados) 
Implmenta estados como el IDLE, INPUT_NUM1, entre etros, se encarga de controlar los registros y enviar señales al display_refresh. 
### 4.7 Display_refresh
Finalmente, este se encarga de mostrar el resultado obtenido, cociente y residuo. 

## 5. Diagrama de máquina de estados 
El diagrama de máquina de estados corresponde a: 

![Diagrama de estaodos](ima/fsm.png)

### 5.1 IDLE
Espera la primera tecla por presionar y además, se encarga de limpiar el sistema. 
### 5.2 INGRESAR_NUM1
Carga los bits correspondientes al registro del dividendo. 
### 5.3 INGRESAR_NUM2
Carga los bits correspondientes al registro del divisor. 
### 5.4 START_DIV
Genera el pulso que señala el inicio de la división. 
### 5.5 ESPERAR_DIV
La máquina de estados espera que el divisor iterativo active done_div. 
### 5.6 MOSTRAR_COCIENTE 
El sistema muestra el cociente obtenido en el display de 7 segmentos. 
### 5.7 MOSTRAR_RESIDUO
Luego de presionar el botón, se muestra el residuo obtenido en el display de 7 segmentos. 

## 6. Simulación funcional 
La simulación del circuito se realizó en un test bench en SystemVerliog, el cual, permite modelar la forma en la que se ejecutaría el algoritmo, desde que se presionan las teclas, hasta que se muestra el resultado final. Esta simulación toma en cuenta las entradas del teclado, los estados de la Finite State Machine, así como las señales de inicio y de salida hasta el display de 7 segmentos. La simulación permite corrobar el flujo correcto del algoritmo. Para este caso, se realizará la simulación de 46_10 (2E_16) entre 5_10 (05_16), el cual corresponde a un cociente de 9 y un residuo de 1.
### 6.1 Ingreso de datos 
En la primera parte, se ingresan los datos que se necesitan, es deicr, el diviendo y el divisor.
-La persona usuaria ingresa los dígitos correspondientes al dividendo: 4 y luego 6.

-Se presiona la tecla configurada como la operación de división.

-Se ingresan los datos correspondientes al divisor, en este caso: 0 y luego 5.

-El usuario presiona la tecla correspondiente a la operación "igual" que ejecuta el comando. 

-Se visualiza el cociente, en este caso "9" , luego el usuario presiona un botón para obtener el cociente, es decir, "1"
### 6.2 Funcionamiento interno 
Una vez la persona usuaria haya ingresado todas las entradas e instrucciones correspondientes, la FSM se asegura de que se carguen correctamente el dividendo y el divisor, así como los registros, así, comienza la iteración. Esta desplaza el residuo y el dividendo, para ello, se toma en cuenta el flanco de reloj,finalmente, se verifica el signo de la misma
### 6.3 Cociente y residuo
En la parte final, es decir, el despliegue de resultados, la FSM controla que se muestre primero el cociente, para ello, el testbench simula la señal del botón presionado que permite mostrar en primer lugar el cociente y luego el resultado. Así se obtiente que: quotient = 9 y remainder = 1. 
-La secuencia de ingreso de datos es interpretada por la FSM. 

-El algoritmo iterativo genera el cociente y el residuo correspondiente. 

-El conversor de Bin a BCD transforma los resultados de binario a decimal. 

-El display de 7 segmentos muestra correctamente el cociente y luego, tras presionar el botón el residuo de la división. 

A continuación, se muestra el wave form generado por el testbench, que refleja la simulación explicada: 

![waveform](ima/waveform.png)

## 7. Reporte de velocidades máximas 
La FPGA utiliza correspnde a la Tang Nano 9k, por lo que, el sistema opera con una señal de reloj máxima de 27MHz, este límite esta definido para poder realizar las funciones de conversión de binario a BCD, así como el debounce, entre otros. 
## 8. Problemas encontrados y sus soluciones 
En este proyecto, los principales problemas encontrados se dieron en el cableado, en primera instancia, se encontraron que ciertos pines del display de 7 segmentos de cuatro dígitos no encendían, esto se solucionó corrigiendo la conexión de los cables, asegurándose que estos realmente hicieran conexión. Similar a este problema, ciertos segmentos del display se veían más tenues que otros, por lo cual también se revisaron las resistencias utilizadas y sus valores para corregirlo. Finalmente, ciertas conexiones se acortaron, con el objetivo de reducir la resistividad, así como, la revisión manual con multímetro del display para garantizar que este funcionara correctamente. 
## 9. Bitácora 
### Jiahui Zhong Xie 

![Jiahui1](ima/jiahui1.png)

![Jiahui2](ima/jiahui2.png)

![Jiahui3](ima/jiahui3.png)

### Ximena Araya Brenes 
![Ximena1](ima/ximena1.png)

![Ximena2](ima/ximena2.png)

![Ximena3](ima/ximena3.png)

![Ximena4](ima/ximena4.png)
