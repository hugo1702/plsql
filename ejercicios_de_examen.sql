/* 1 Crear e invocar el procedimiento ADD_JOB y considerar los resultados. 
a. Crea un procedimiento llamado ADD_JOB para insertar un nuevo puesto en la tabla JOBS. 
Proporciona el ID y el título del puesto como dos parámetros. 
b. Compila el código e invoca el procedimiento pasando IT_DBA como ID del puesto y 
Administrador de Base de Datos como título.  */

CREATE OR REPLACE PROCEDURE ADD_JOB ( p_job_id IN JOBS.JOB_ID%TYPE, p_job_titulo IN JOBS.JOB_TITLE%TYPE) IS
BEGIN
    INSERT INTO JOBS (JOB_ID, JOB_TITLE)
    VALUES (p_job_id, p_job_titulo);
    DBMS_OUTPUT.PUT_LINE('Insertado conrectamente: ' || p_job_id || ' - ' || p_job_titulo);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END ADD_JOB;
/

BEGIN
    ADD_JOB('IT_DBA', 'Administrador de Base de Datos');
END;
/


/* 2 Crea un procedimiento llamado UPD_JOB para modificar un puesto en la tabla JOBS. 
a. Crea un procedimiento llamado UPD_JOB que actualice el título del puesto. Proporciona el ID 
del puesto y un nuevo título como dos parámetros. Incluye el manejo de excepciones necesario 
para el caso de que no se realice ninguna actualización. 
b. Compila el código; invoca el procedimiento para cambiar el título del puesto con ID IT_DBA a 
Administrador de Datos. Consulta la tabla JOBS para ver los resultados. */

CREATE OR REPLACE PROCEDURE UPD_JOB(p_job_id IN jobs.job_id%TYPE, p_nuevo_titulo  IN jobs.job_title%TYPE) IS 

BEGIN
    UPDATE jobs
    SET job_title = p_nuevo_titulo
    WHERE job_id = p_job_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se actualizó ningún registro. Verifica el JOB_ID.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Puesto actualizado correctamente.');
    END IF;
END;
/

BEGIN
    UPD_JOB('IT_DBA', 'Preba de cambio.');
END;


/* 3 Crea una función llamada ANNUAL_COMP que devuelva el salario anual aceptando dos 
parámetros: el salario mensual de un empleado y su comisión. La función debe gestionar 
valores NULL: uno o ambos parámetros pueden ser NULL, pero aún así debe devolver siempre 
un salario anual que no sea NULL. El salario anual se calcula según la fórmula básica: 
(salary * 12) + (commission_pct * salary * 12) */ 

CREATE OR REPLACE FUNCTION ANNUAL_COMP (
    p_salario IN NUMBER,
    p_commission_pct IN NUMBER
) RETURN NUMBER IS
    v_salario_anual NUMBER;
BEGIN
    v_salario_anual := NVL(p_salario, 0) * 12 +
    NVL(p_commission_pct, 0) * NVL(p_salario, 0) * 12;

    RETURN v_salario_anual;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('salario anual: ' || ANNUAL_COMP(3000, 0.10));
    DBMS_OUTPUT.PUT_LINE('salario anual sin comision: ' || ANNUAL_COMP(4000, NULL));
    DBMS_OUTPUT.PUT_LINE('salario anual sin salario: ' || ANNUAL_COMP(NULL, 0.15));
END;

