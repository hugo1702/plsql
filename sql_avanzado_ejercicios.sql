/*1. Escribe una consulta que muestre el employee_id, job_id 
y department_id de la tabla EMPLOYEES y de la tabla 
JOB_HISTORY, sin duplicados.*/

SELECT employee_id, job_id, department_id 
FROM employees
UNION
SELECT employee_id, job_id, department_id
FROM job_history;

/*2. Muestra los empleados (employee_id, job_id) que actualmente 
tienen el mismo puesto que alguno que ya ocuparon antes.*/

SELECT e.employee_id, e.job_id, jh.job_id
FROM employees e
JOIN job_history jh ON e.employee_id = jh.employee_id
AND e.job_id = jh.job_id;

/*3. Consulta que muestre el total de salarios por 
department_id y job_id, incluyendo subtotales por 
departamento y total general. */

SELECT department_id, job_id, SUM(salary) AS total_salario
FROM employees
GROUP BY ROLLUP(department_id, job_id);

/* 4.  Escribe una consulta jerárquica para mostrar la cadena 
de mando desde el empleado jefe (sin manager_id) hasta 
los empleados subordinados, incluyendo el nivel 
jerárquico (LEVEL) y usando sangría (LPAD). */

SELECT LPAD(' ', LEVEL * 2) || first_name || ' ' || last_name AS empleado,
    employee_id,
    manager_id,
    LEVEL AS nivel_jerarquico
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;


/* 6. Muestra los empleados cuyo salario es mayor al promedio 
de salario de su propio departamento.  */ 

SELECT e.employee_id, e.first_name, e.last_name, e.salary
FROM employees e
WHERE salary > (SELECT AVG(salary) FROM employees WHERE department_id = e.department_id);

/*7. Usa WITH para definir un bloque que calcule el salario 
promedio por department_id. Luego selecciona los 
empleados cuyo salario sea mayor al promedio de su 
departamento.  */ 

WITH promedio_salario AS (
    SELECT department_id, AVG(salary) AS salario_promedio
    FROM employees 
    GROUP BY department_id)

SELECT e.employee_id, e.first_name, e.last_name, e.salary, e.department_id,
FROM employees e 
JOIN promedio_salario p ON e.department_id = p.department_id
WHERE salary > p.salario_promedio;

/*8. Muestra los nombres y apellidos de los empleados que han 
trabajado previamente en algún departamento distinto al 
actual. */ 

SELECT DISTINCT 
    e.first_name, e.last_name, e.department_id, jh.department_id
FROM employees e
INNER JOIN job_history jh ON e.employee_id = jh.employee_id
WHERE jh.department_id <> e.department_id;

/* 9. Muestra los departamentos cuyo promedio de salario es 
mayor a $7000.  */

SELECT department_id, AVG(salary)
FROM employees 
GROUP BY department_id
HAVING AVG(salary) > 7000;

/*10. Muestra los employee_id de los empleados que no 
aparecen en el historial de trabajos (JOB_HISTORY). */ 

SELECT e.employee_id
FROM employees e
LEFT JOIN job_history jh ON e.employee_id = jh.employee_id
WHERE jh.employee_id IS NULL;



/* */ 

SELECT manager_id , COUNT(*) AS empleados_a_cargo
FROM employees
GROUP BY manager_id;