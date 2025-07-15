/* 4 Crea una especificación de paquete y un cuerpo de paquete llamados JOB_PACK. (Puedes 
guardar la especificación y el cuerpo en dos archivos separados). 
Este paquete debe contener tus procedimientos ADD_JOB, UPD_JOB y DEL_JOB, así como tu 
función QF_JOB.*/ 

CREATE OR REPLACE PACKAGE JOB_PACK IS
    PROCEDURE ADD_JOB(p_job_id IN VARCHAR2, p_job_titulo VARCHAR2);
    PROCEDURE UPD_JOB (p_job_id IN VARCHAR2, p_nuevo_titulo VARCHAR2);
    PROCEDURE DEL_JOB(p_job_id IN VARCHAR2);
END JOB_PACK;
/

CREATE OR REPLACE PACKAGE BODY JOB_PACK IS 
    -- precedimineto ADD_JOB
    PROCEDURE ADD_JOB(p_job_id IN VARCHAR2, p_job_titulo IN VARCHAR2) IS
    BEGIN
        INSERT INTO JOBS (JOB_ID, JOB_TITLE)
        VALUES (p_job_id, p_job_titulo);
        DBMS_OUTPUT.PUT_LINE('Insertado conrectamente: ' || p_job_id || ' - ' || p_job_titulo);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END ADD_JOB;
    
    -- precedimineto UPD_JOB
    PROCEDURE UPD_JOB(p_job_id IN VARCHAR2, p_nuevo_titulo IN VARCHAR2) IS
    BEGIN
        UPDATE JOBS
        SET JOB_TITLE = p_nuevo_titulo
        WHERE JOB_ID = p_job_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No se actualizó ningún registro. Verifica el JOB_ID.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Puesto actualizado correctamente.');
        END IF;
    END UPD_JOB;
    
    -- precedimineto DEL_JOB
    PROCEDURE DEL_JOB(p_job_id IN VARCHAR2) IS
    BEGIN
        DELETE 
        FROM jobs
        WHERE job_id = p_job_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No se encontro el JOB_ID: ' || p_job_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Puesto eliminado: ' || p_job_id);
        END IF;
    END DEL_JOB;
END JOB_PACK; 
/

/*Nota: El procedimiento DEL_JOB no se realizo en los ejercicios anteriores, pero fue agregado al paquete como DELETE,
en cuanto a QF_JOB, no se especificó su funcionalidad, por lo tanto, no se incluyó en el paquete.
*/  

/* pruebas de los procediminetos (INSERT, UPDATE y DELETE)*/

BEGIN
    job_pack.add_job('IT_DBA3', 'Administrador de Base de Datos');
END;

BEGIN
    job_pack.upd_job('IT_DBA3', 'Administrador de Datos');
END;

BEGIN
    job_pack.del_job('IT_DBA3');
END;





