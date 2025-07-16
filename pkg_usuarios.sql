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
                        