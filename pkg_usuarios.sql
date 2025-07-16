CREATE OR REPLACE PACKAGE pkg_usuarios AS 
    PROCEDURE insertar_usuario(
    p_nombre IN usuarios.nombre%TYPE,
    p_apellido IN usuarios.apellido%TYPE,
    p_correo IN usuarios.correo%TYPE);
    
    PROCEDURE listar_usuarios;
    
    PROCEDURE eliminar_usuario(p_usuario_id IN usuarios.id_usuario%TYPE);
END pkg_usuarios;
/

CREATE OR REPLACE PACKAGE BODY pkg_usuarios AS 
    PROCEDURE insertar_usuario(
        p_nombre IN usuarios.nombre%TYPE,
        p_apellido IN usuarios.apellido%TYPE,
        p_correo IN usuarios.correo%TYPE) IS
    BEGIN
        INSERT INTO usuarios (nombre, apellido, correo, fecha_registro)
        VALUES (p_nombre, p_apellido, p_correo, SYSDATE);
        
        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No se pudo insertan el nuevo usuario.');
        ELSE 
            DBMS_OUTPUT.PUT_LINE('Se registró correctamente al usuario.' || p_nombre);
        END IF;
    EXCEPTION 
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('OCURRIO un error: ' || SQLERRM);
    END;
    
    PROCEDURE listar_usuarios AS 
    CURSOR c_usuario IS 
        SELECT id_usuario, nombre, apellido, correo, fecha_registro
        FROM usuarios;
        
        v_id usuarios.id_usuario%TYPE;
        v_nombre usuarios.nombre%TYPE;
        v_apellido usuarios.apellido%TYPE;
        v_correo usuarios.correo%TYPE;
        v_fecha_registro usuarios.fecha_registro%TYPE;
        
    BEGIN 
        OPEN c_usuario;
            LOOP
                FETCH c_usuario INTO v_id, v_nombre, v_apellido, v_correo, v_fecha_registro;
                EXIT WHEN c_usuario%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE( v_id|| ' ' ||'NOMBRE: ' || v_nombre || ' ' || v_apellido || ' CORREO: ' || v_correo ||
                ' FECHA DE REGISTRO:' || v_fecha_registro);
            END LOOP;
        CLOSE c_usuario;       
    END;
        
END pkg_usuarios;

-- falte el procedimiento de editar y eliminar.
/

BEGIN 
    pkg_usuarios.insertar_usuario('CARLOS ALBERTO', 'HERNANDEZ CONSTANTINO', 'hugonorberton@gmail.com');
END;

BEGIN
    pkg_usuarios.listar_usuarios;
END;
/



SELECT MIN(min_salary)
FROM JOBS;

SELECT e.*
FROM employees e
WHERE e.job_id = (
    SELECT job_id
    FROM jobs
    WHERE min_salary = (
        SELECT MIN(min_salary)
        FROM jobs
    )
);


SELECT employee_id
FROM employees e 
WHERE job_id = (SELECT job_id FROM jobs WHERE min_salary = (SELECT MIN(min_salary) FROM jobs));

/* Crear un procedimiento que:
Identifique el departamento con el promedio salarial más bajo.
Aumente en un porcentaje dado el salario de todos los empleados de ese departamento.
Muestre cuántos empleados fueron afectados.
Maneje errores y muestre mensajes claros con DBMS_OUTPUT. */ 

CREATE OR REPLACE PROCEDURE aumentar_salario_departamento_pobre (
    p_porcentaje_aumento IN NUMBER) IS
    
    CURSOR c_emp IS 
        SELECT employee_id
        FROM employees e 
        WHERE job_id = (SELECT job_id FROM jobs WHERE min_salary = (SELECT MIN(min_salary) FROM jobs));
    
    v_empleado_id employees.employee_id%TYPE;
    v_contador NUMBER := 0;
        
BEGIN 
    OPEN c_emp;
        LOOP
            FETCH c_emp INTO v_empleado_id;
            EXIT WHEN c_emp%NOTFOUND;
            
            UPDATE employees 
            SET salary = salary + (salary * p_porcentaje_aumento)
            WHERE employee_id = v_empleado_id;
            DBMS_OUTPUT.PUT_LINE('ID DE EMPEADO CON SALARIO AUMENTODO: ' || v_empleado_id);
            v_contador := v_contador + 1;
        END LOOP;
    CLOSE c_emp;
    DBMS_OUTPUT.PUT_LINE('TOTAL DE EMPLEADOS MODIFCADOS: ' || v_contador);
EXCEPTION 
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR' || SQLERRM);
END aumentar_salario_departamento_pobre;

BEGIN 
    aumentar_salario_departamento_pobre(0.10);
END;
/



CREATE OR REPLACE PROCEDURE listar_emp_depto( p_departamento_id IN employees.department_id%TYPE) IS
    CURSOR c_emp IS 
    SELECT employee_id, first_name, last_name, salary 
    FROM employees
    WHERE department_id = p_departamento_id;
    
    v_empleado_id employees.employee_id%TYPE;
    v_nombre employees.first_name%TYPE;
    v_apellido employees.last_name%TYPE;
    v_salario employees.salary%TYPE;
    v_contador NUMBER := 0;
BEGIN
    OPEN c_emp;
        LOOP 
            FETCH c_emp INTO v_empleado_id,  v_nombre, v_apellido, v_salario;
            EXIT WHEN c_emp%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_empleado_id ||' ' || 'NOMBERE: ' || v_nombre || ' ' || v_apellido || ' SALARIO: ' || v_salario );
            v_contador := v_contador + 1;
        END LOOP;
    CLOSE c_emp;
    DBMS_OUTPUT.PUT_LINE('NUMERO DE REGISTROS ENCONTRADOS: ' || v_contador);
END listar_emp_depto; 
/

BEGIN
    listar_emp_depto(90);
END;
/

CREATE OR REPLACE PACKAGE pkg_employees_p AS 
    PROCEDURE listar_emepleados_por_depto(p_departamento_id IN employees.department_id%TYPE);
END pkg_employees_p;
/

CREATE OR REPLACE PACKAGE BODY pkg_employees_p AS 
        PROCEDURE listar_emepleados_por_depto(p_departamento_id IN employees.department_id%TYPE) IS
            CURSOR c_emp IS 
                SELECT first_name, last_name, salary
                FROM employees
                WHERE department_id = p_departamento_id;
                
            TYPE r_empleados IS RECORD(
                nombre employees.first_name%TYPE,
                apellido employees.last_name%TYPE,
                salario employees.salary%TYPE
             ); 

            v_empleado r_empleados;
            v_contador NUMBER:= 0;
        BEGIN 
            OPEN c_emp;
                LOOP 
                    FETCH c_emp INTO v_empleado;
                    EXIT WHEN c_emp%NOTFOUND;
                    DBMS_OUTPUT.PUT_LINE('NOMBRE: ' || v_empleado.nombre || ' ' || v_empleado.apellido || ' SALARIO: '|| v_empleado.salario);
                    v_contador := v_contador + 1; 
                END LOOP;
            CLOSE c_emp;
            
            IF v_contador = 0 THEN
                DBMS_OUTPUT.PUT_LINE('No se encontraro  registros encontrados.');
            ELSE 
                DBMS_OUTPUT.PUT_LINE('Registros encontrados: ' || v_contador);
            END IF;
            
        EXCEPTION 
        
            WHEN OTHERS THEN 
                DBMS_OUTPUT.PUT_LINE('ERROR:' || SQLERRM);
    END listar_emepleados_por_depto;
END pkg_employees_p;
/

BEGIN 
    pkg_employees_p.listar_emepleados_por_depto(90);
END;
/

CREATE OR REPLACE PROCEDURE listar_emp_r(p_departamento_id IN employees.department_id%TYPE) IS 
    CURSOR c_emp IS 
    SELECT * 
    FROM employees
    WHERE department_id = p_departamento_id;
    
    r_empleados c_emp%ROWTYPE;
    
    BEGIN 
    OPEN c_emp;
        LOOP 
            FETCH c_emp INTO r_empleados;
            EXIT WHEN c_emp%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(r_empleados.first_name|| ' ' || r_empleados.last_name);
        END LOOP;
    CLOSE c_emp;
END listar_emp_r;
/

BEGIN
    listar_emp_r(90);
END;
/

CREATE OR REPLACE PROCEDURE aumento_salario IS
    CURSOR c_emp IS 
        SELECT e.employee_id
        FROM employees e
        WHERE department_id IN (SELECT department_id
                                FROM employees
                                GROUP BY department_id
                                HAVING AVG(salary) <= 5000);
                                
        v_empleado c_emp%ROWTYPE;
        v_contador NUMBER := 0;
    
    BEGIN 
        OPEN c_emp;
            LOOP
                FETCH c_emp INTO v_empleado;
                EXIT WHEN c_emp%NOTFOUND;
                
                UPDATE employees
                SET salary = salary + (salary * 0.15)
                WHERE employee_id = v_empleado.employee_id;
                DBMS_OUTPUT.PUT_LINE('EMPLEADO MODIFICADO: ' || v_empleado.employee_id);
                v_contador := v_contador + 1;
            END LOOP;
        CLOSE c_emp;
        IF v_contador > 0 THEN
            DBMS_OUTPUT.PUT_LINE('TOTAL DE REGISTRO MODIFICADOS: ' || v_contador);
        ELSE 
            DBMS_OUTPUT.PUT_LINE('NO SE ENCONTRARON REGISTRO :(');
        END IF;
    EXCEPTION 
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END aumento_salario;
/

BEGIN 
    aumento_salario;
END;
/




SELECT e.employee_id, e.salary
FROM employees e
WHERE department_id IN (SELECT department_id
                        FROM employees
                        GROUP BY department_id
                        HAVING AVG(salary) <= 6000);
                        
SELECT AVG(salary)
FROM employees
GROUP BY department_id 
HAVING AVG(salary) <= 6000;
                        


/*Ejercicio 18: Cursores Explícitos con Parámetros
Problema: Declara un cursor explícito que reciba un p_job_id y retorne el first_name, last_name y salary 
de los empleados que tienen ese job_id. Abre el cursor para el job_id = 'IT_PROG' (Programadores de TI), 
itera sobre los resultados e imprime la información de cada empleado.*/

DECLARE 
    CURSOR c_emp IS 
        SELECT first_name, last_name, salary
        FROM employees
        WHERE job_id = 'IT_PROG';
    
    
    
BEGIN 
END;
/

CREATE OR REPLACE PROCEDURE get_employees(
    p_job_id employees.job_id%TYPE) IS 
    CURSOR c_emp IS 
        SELECT first_name, last_name, salary
        FROM employees
        WHERE job_id = p_job_id;
        
    v_empleados c_emp%ROWTYPE;
    
BEGIN 
    OPEN c_emp;
        LOOP
            FETCH c_emp INTO v_empleados;
            EXIT WHEN c_emp%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('NOMBRE: ' || v_empleados.first_name || ' ' || v_empleados.last_name || ' SALARIO:' ||  v_empleados.salary);
        END LOOP;
    CLOSE c_emp;
END get_employees;
    
BEGIN 
    get_employees('IT_PROG');
END;
/
    
/*Ejercicio 20: Usando %ROWTYPE y Bucle FOR con JOINS
Problema: Recorre todos los empleados que tienen un manager (es decir, manager_id no es nulo). Para cada uno,
imprime su first_name, last_name, el job_title y el department_name
al que pertenece. Utiliza %ROWTYPE para el registro del cursor.*/

DECLARE
    CURSOR c_emp IS 
    SELECT e.first_name, e.last_name, j.job_title, d.department_name
    FROM employees e 
    JOIN jobs j ON e.job_id = j.job_id
    JOIN departments d ON e.department_id = d.department_id
    WHERE e.manager_id IS NOT NULL;
    
    v_empleado c_emp%ROWTYPE;
BEGIN 
        FOR v_empleado IN  c_emp LOOP 
            DBMS_OUTPUT.PUT_LINE('NOMBRE: ' || v_empleado.first_name || ' APELLIDO: ' || v_empleado.last_name ||
            ' JOB_TITTLE: ' || v_empleado.job_title || ' DEPdcdARTAMENT_ID: ' || v_empleado.department_name );
        END LOOP;
END;
/

/* Tema: Procedimientos, IF, condiciones simples
Instrucciones:
Crea un procedimiento llamado verificar_salario que reciba como parámetro el employee_id.
El procedimiento debe:
Buscar el salario del empleado.
Si el salario es menor a 3000, mostrar "Salario bajo".
Si el salario está entre 3000 y 7000, mostrar "Salario medio".
Si el salario es mayor a 7000, mostrar "Salario alto" */ 

CREATE OR REPLACE PROCEDURE verificar_salario(
    p_employee_id IN employees.employee_id%TYPE ) IS 
        v_nombre employees.first_name%TYPE;
        v_apellido employees.last_name%TYPE;
        v_salario employees.salary%TYPE;
        status_salario VARCHAR2(100);
        
        BEGIN 
        
        SELECT first_name, last_name, salary
        INTO v_nombre, v_apellido, v_salario
        FROM employees
        WHERE employee_id = p_employee_id;
        
        IF v_salario < 3000 THEN 
            status_salario := 'Salario bajo';
        ELSIF v_salario BETWEEN 3000 AND 7000 THEN
            status_salario := 'Salario medio';
        ELSIF v_salario > 7000 THEN 
            status_salario := 'Salario alto'; 
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('NOMBRE: ' || v_nombre || ' ' || v_apellido || ' SALARIO: ' || v_salario || ' STATUS DE SALARIO: ' || status_salario);
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            DBMS_OUTPUT.PUT_LINE('No se encontraron datos ID.');
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END verificar_salario; 
/
            
BEGIN
    verificar_salario(1000);
END;
/


/* Ejercicio 2: Cursor con bucle FOR
Tema: Cursores, bucles
Instrucciones:
Declara un cursor que seleccione todos los empleados que tienen un manager asignado (es decir, manager_id IS NOT NULL).
Recorre ese cursor usando un bucle FOR e imprime por cada empleado:

Su first_name, last_name y department_id. */

DECLARE 
    CURSOR c_emp IS 
    SELECT first_name, last_name, salary 
    FROM employees
    WHERE manager_id IS NOT NULL;

BEGIN 
    FOR r_empleados IN c_emp LOOP
        DBMS_OUTPUT.PUT_LINE('NOMBRE: ' || r_empleados.first_name || ' ' || r_empleados.last_name || ' SALARIO: ' || r_empleados.salary);
    END LOOP;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No se encotraron datos.');
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;


/* Ejercicio 2: Cursor con bucle FOR
Tema: Cursores, bucles
Instrucciones:
Declara un cursor que seleccione todos los empleados que tienen un manager asignado (es decir, manager_id IS NOT NULL).
Recorre ese cursor usando un bucle FOR e imprime por cada empleado:

Su first_name, last_name y department_id. */

DECLARE 
    CURSOR c_emp IS 
    SELECT first_name, last_name, salary 
    FROM employees
    WHERE manager_id IS NOT NULL;

BEGIN 
    FOR r_empleados IN c_emp LOOP
        DBMS_OUTPUT.PUT_LINE('NOMBRE: ' || r_empleados.first_name || ' ' || r_empleados.last_name || ' SALARIO: ' || r_empleados.salary);
    END LOOP;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No se encotraron datos.');
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

/* 🟦 Ejercicio: Evaluar Bonificación por Antigüedad
Tema: Procedimientos, condiciones IF, funciones de fecha
Instrucciones:

Crea un procedimiento llamado evaluar_bonificacion que reciba como parámetro el employee_id. El procedimiento debe:

Obtener la fecha de contratación (hire_date) del empleado.

Calcular cuántos años completos lleva trabajando en la empresa.
Según los años, mostrar el mensaje correspondiente:
Menos de 1 año: "Sin bonificación"
Entre 1 y 3 años: "Bonificación básica"
Entre 4 y 5 años: "Bonificación media"
Más de 5 años: "Bonificación alta"
Imprimir también el nombre del empleado y los años trabajados. */ 

DECLARE
    CURSOR c_emp IS 
        SELECT employee_id, first_name, last_name, CAST(TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) AS INTEGER ) AS meses
        FROM EMPLOYEES;
    v_status_antiguedad VARCHAR2(100);
BEGIN 
    FOR r_emp IN c_emp LOOP
    
        IF r_emp.meses < 1 THEN
            v_status_antiguedad := 'Sin bonificación';
        ELSIF r_emp.meses BETWEEN 1 AND 3 THEN
            v_status_antiguedad := '"Bonificación básica';
        ELSIF r_emp.meses BETWEEN 4 AND 5 THEN
            v_status_antiguedad := '"Bonificación media';
        ELSIF r_emp.meses > 5 THEN
            v_status_antiguedad := '"Bonificación alta';
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('NOMBRE: '|| r_emp.first_name || ' ' || r_emp.last_name || ' AÑOS TRABAJANDO: ' || r_emp.meses || ' TIPO DE BONIFICACION: ' || v_status_antiguedad );
    END LOOP;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron datos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR:' || SQLERRM);
END;
/




