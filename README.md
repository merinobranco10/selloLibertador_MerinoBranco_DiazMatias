# Sello Libertador: Bloque 3 (Módulo C)

Criptografía y Blockchain, Universidad Bernardo O'Higgins.
Integrantes: Branco Merino H., Matías Díaz Zamora.

Módulo de verificación y enlace: responde si un documento corresponde a un título válido.

## Contenido

- `contracts/moduloC/VerificadorUBO.sol`: `verificar` (función `view`). Orden de comprobación: Inexistente, EmisorNoAutorizado (fecha de emisión), Revocado, Suspendido, DocumentoAlterado, Valido.
- `contracts/moduloC/HerramientasSello.sol`: `byteAceptado`, `simboloDe` y `derivarLocalizador` (localizador de 10 símbolos `[0-9A-Z]` sin sesgo de módulo).
- `docs/`: informe del Hito 1.

## Estado

| Hito | Contenido | Estado |
|---|---|---|
| 1 | `verificar`, `byteAceptado`, `simboloDe`, `derivarLocalizador` | Entregado |
| 2 | `AnclajeLotes`, `raizDeMerkle` | Pendiente |
| 3 | `verificarConExplicacion`, seguridad del enlace | Pendiente |

## Cómo probarlo

1. En https://app.remix.live, clonar `https://github.com/ser-web/sello-libertador`.
2. Reemplazar los dos archivos de `contracts/moduloC/` por los de este repositorio.
3. Ajustes: compilador 0.8.20, EVM default, optimización 200, *Generate contract metadata* activado, entorno Remix VM.
4. Ejecutar `tests/ModuloC_test.sol`. En el Hito 1 pasan 2 pruebas (*Veredicto valido* y *Documento alterado un caracter*); las otras 6 fallan con TODO, como se espera.

Las carpetas `interfaces`, `comun`, `simulacros` y `scripts` son del repositorio del curso y no se incluyen aquí.
