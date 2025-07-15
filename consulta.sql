
CREATE OR REPLACE PACKAGE BODY pkg_crud_emp AS 
     PROCEDURE listar_emp IS
        CURSOR c_emp IS 
            SELECT first_name, last_name, salary 
            FROM employees;
            
        v_nombre employees.first_name%TYPE;
        v_apellido employees.last_name%TYPE;
        v_salario employees.salary%TYPE;
        
    BEGIN 
        OPEN c_emp;
            LOOP 
                FETCH c_emp INTO v_nombre, v_apellido, v_salario;
                DBMS_OUTPUT.PUT_LINE('NOMBRE; ' || v_nombre || ' ' || v_apellido || 'SALARIO: ' || v_salario);
                EXIT WHEN c_emp%NOTFOUND;
            END LOOP;
        CLOSE c_emp;
    END listar_emp;
    
    PROCEDURE insertar_emp(
        p_nombre IN employees.first_name%TYPE, 
        p_apellido IN employees.last_name%TYPE, 
        p_email IN employees.email%TYPE,
        p_fecha_contrato employees.hire_date%TYPE,
        p_salario employees.salary%TYPE,
        p_deparatmaneto_id employees.department_id%TYPE) IS 
        
    BEGIN 
        INSERT INTO employees (first_name, last_name, email, hire_date, salary, department_id)
        VALUES (p_nombre, p_apellido, p_email, p_fecha_contrato, p_salario, p_deparatmaneto_id);
        
        
        IF SQL%ROWCOUNT > 0 THEN 
            DBMS_OUTPUT.PUT_LINE('Se insertó correctamente al empleado: ' || p_nombre || ' ' || p_apellido);
        ELSE 
            DBMS_OUTPUT.PUT_LINE('Error la registrar al empleado. ');
        END IF;
        
        EXCEPTION 
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    END insertar_emp;
    
    PROCEDURE modificar_salario_emp(p_empleado_id IN employees.employee_id%TYPE, p_salario IN employees.salary%TYPE) IS 
    BEGIN
        UPDATE employees
        SET salary = p_salario
        WHERE employee_id = p_empleado_id;
        
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Se modifico correctamente al empleado: ' || p_empleado_id);
        ELSE 
            DBMS_OUTPUT.PUT_LINE('No se pudo actualizar el salario del empleado: ' || p_empleado_id);
        END IF;
        EXCEPTION 
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        END modificar_salario_emp;
        
        PROCEDURE eliminar_empleado(p_empleado_id employees.employee_id%TYPE) IS
        BEGIN
            DELETE employees
            WHERE employee_id = p_empleado_id;
            
            IF SQL%ROWCOUNT > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Se elimino corectamente al empleado');
            ELSE
                DBMS_OUTPUT.PUT_LINE('No se pudo eliminar al emplado.');
            END IF;
        EXCEPTION 
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    END eliminar_empleado;
END pkg_crud_emp;




/* */ 

/* Insertar un empleado solo si su correo electrónico no está ya registrado (usa SELECT INTO y EXCEPTION). */ 

CREATE OR REPLACE PROCEDURE cambiar_departamento(
    p_departamento IN employees.department_id%TYPE, 
    p_nuevo_departamento IN employees.department_id%TYPE) IS 
    
    CURSOR c_depto IS 
        SELECT employee_id 
        FROM employees
        WHERE department_id = p_departamento;
    
    v_empleado_id employees.employee_id%TYPE;
    v_departamento_id employees.department_id%TYPE;
    
    BEGIN 
        OPEN c_depto;
            LOOP
                 FETCH c_depto INTO v_empleado_id;
                EXIT WHEN c_depto%NOTFOUND;
        
                UPDATE employees
                SET department_id = p_nuevo_departamento
                WHERE employee_id = v_empleado_id;
        
                DBMS_OUTPUT.PUT_LINE('Se cambió el empleado: ' || v_empleado_id || ' al depto: ' || p_nuevo_departamento);  
            END LOOP;
        CLOSE c_depto;
END cambiar_departamento;


BEGIN
    cambiar_departamento(80, 90);
END;

SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = 90;

/* Crea una función que devuelva el número de empleados en un departamento dado. */ 

CREATE OR REPLACE FUNCTION total_empleados_dpto (p_departamento_id IN employees.department_id%TYPE) 
RETURN NUMBER
IS 

    v_total_empleados NUMBER;
    
BEGIN 
    SELECT COUNT(*)
    INTO v_total_empleados
    FROM employees
    WHERE department_id = p_departamento_id;
    
    DBMS_OUTPUT.PUT_LINE('ID_DEPARTAMENTO: ' || p_departamento_id || ' TOTAL DE EMPLEADOS: ' || v_total_empleados );
    RETURN v_total_empleados;
    
END total_empleados_dpto;
/



DECLARE
    v_total NUMBER;
BEGIN
    v_total := total_empleados_dpto(90);
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




