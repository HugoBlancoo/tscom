<a href="https://github.com/HugoBlancoo/tscom/graphs/contributors" title="Contributors"><img src="https://img.shields.io/github/contributors/HugoBlancoo/tscom"></a>
<a href="https://github.com/HugoBlancoo/tscom/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/HugoBlancoo/tscom"></a>

# TSCOM

Repositorio con las prácticas del curso "Signal Processing for Communications" (TSCOM) del Máster en Ingeniería de Telecomunicación — Universidade de Vigo.

## Resumen / Summary

Aquí se subirán las prácticas (informes, código Matlab/Octave y ficheros LaTeX) realizadas para la asignatura TSCOM.  
This repository contains lab assignments (reports, Matlab/Octave code and LaTeX sources) for the TSCOM course.

## Estructura principal / Main structure

- practicas/ : cada práctica en su subcarpeta (latex, matlab, imágenes, datos).
  - practicas/practica1/latex/ : fuentes LaTeX del informe — ejemplo: [practicas/practica1/latex/practica1.tex](practicas/practica1/latex/practica1.tex) y [practicas/practica1/latex/appendix.tex](practicas/practica1/latex/appendix.tex).  
  - practicas/practica1/matlab/ : scripts y funciones Matlab — ejemplo: [`quanti`](practicas/practica1/matlab/quanti.m), [`dquanti`](practicas/practica1/matlab/dquanti.m) y scripts de tareas (p. ej. [practicas/practica1/matlab/task3.m](practicas/practica1/matlab/task3.m), [practicas/practica1/matlab/task6_3.m](practicas/practica1/matlab/task6_3.m)).

## Cómo usar / How to use

- Compilar el informe LaTeX (ejemplo para práctica 1):
  - desde la carpeta correspondiente ejecutar un compilador LaTeX (p. ej. latexmk o pdflatex):
    - latexmk -pdf practicas/practica1/latex/practica1.tex
- Ejecutar scripts Matlab/Octave:
  - Abrir Matlab en la carpeta del proyecto y ejecutar los scripts en practicas/practicaX/matlab/, p. ej.:
    - run('practicas/practica1/matlab/task3.m')
  - Las funciones de cuantización relevantes están en [`practicas/practica1/matlab/quanti.m`](practicas/practica1/matlab/quanti.m) y [`practicas/practica1/matlab/dquanti.m`](practicas/practica1/matlab/dquanti.m).

## Buenas prácticas / Notes

- Mantener organizadas las figuras en practicas/practicaX/latex/img/ para que LaTeX las incluya correctamente.
- Versionar los cambios en Git y escribir commits claros para cada modificación de código o informe.

## Contribuir / Contributing

1. Crear una rama por práctica o por feature.
2. Incluir código reproducible y, si procede, scripts para generar figuras.
3. Abrir un PR con descripción de cambios.

---
Repositorio usado para las prácticas del Máster en Ingeniería de Telecomunicación (Universidade de Vigo).
