

/*✅ 1. Bloque Anónimo (sin guardar)*/

DECLARE
   v_nombre employees.first_name%TYPE;
BEGIN
   SELECT first_name INTO v_nombre
   FROM employees
   WHERE employee_id = 100;

   DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No se encontró el empleado.');
END;

/*✅ 2. Procedimiento*/

CREATE OR REPLACE PROCEDURE saludar_empleado (
   p_id IN employees.employee_id%TYPE
)
IS
   v_nombre employees.first_name%TYPE;
BEGIN
   SELECT first_name INTO v_nombre
   FROM employees
   WHERE employee_id = p_id;

   DBMS_OUTPUT.PUT_LINE('Hola, ' || v_nombre || '!');
END;
/* ✅ 3. Función */

CREATE OR REPLACE FUNCTION obtener_salario (
   p_id IN employees.employee_id%TYPE
) RETURN NUMBER
IS
   v_salario employees.salary%TYPE;
BEGIN
   SELECT salary INTO v_salario
   FROM employees
   WHERE employee_id = p_id;

   RETURN v_salario;
END;
/*✅ 4. Cursor SIMPLE (FOR loop) */

DECLARE
   CURSOR c_emp IS
      SELECT first_name, salary FROM employees WHERE department_id = 10;
BEGIN
   FOR r IN c_emp LOOP
      DBMS_OUTPUT.PUT_LINE(r.first_name || ' - $' || r.salary);
   END LOOP;
END;
/*✅ 5. Cursor EXPLÍCITO (OPEN/FETCH/CLOSE) */

DECLARE
   CURSOR c_emp IS
      SELECT employee_id, salary FROM employees;
   v_id employees.employee_id%TYPE;
   v_salary employees.salary%TYPE;
BEGIN
   OPEN c_emp;
   LOOP
      FETCH c_emp INTO v_id, v_salary;
      EXIT WHEN c_emp%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ' Salario: ' || v_salary);
   END LOOP;
   CLOSE c_emp;
END;
/*✅ 6. IF - ELSIF - ELSE */
IF v_salario < 3000 THEN
   DBMS_OUTPUT.PUT_LINE('Salario bajo');
ELSIF v_salario BETWEEN 3000 AND 6000 THEN
   DBMS_OUTPUT.PUT_LINE('Salario medio');
ELSE
   DBMS_OUTPUT.PUT_LINE('Salario alto');
END IF;
/*✅ 7. Ciclo FOR */
 
FOR i IN 1..5 LOOP
   DBMS_OUTPUT.PUT_LINE('Número: ' || i);
END LOOP;
/*✅ 8. Ciclo WHILE*/

DECLARE
   v_contador NUMBER := 1;
BEGIN
   WHILE v_contador <= 5 LOOP
      DBMS_OUTPUT.PUT_LINE('Contador: ' || v_contador);
      v_contador := v_contador + 1;
   END LOOP;
END;
/*✅ 9. Manejo de Excepciones*/

BEGIN
   -- Supongamos una búsqueda
   SELECT salary INTO v_salario
   FROM employees
   WHERE employee_id = 999; -- ID inexistente

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Empleado no encontrado');
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/*✅ 10. CASE */

CASE v_departamento_id
   WHEN 10 THEN DBMS_OUTPUT.PUT_LINE('Administración');
   WHEN 20 THEN DBMS_OUTPUT.PUT_LINE('Ventas');
   ELSE DBMS_OUTPUT.PUT_LINE('Otro');
END CASE;