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

