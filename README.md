# Sello Libertador: Bloque 3 (Módulo C)

Criptografía y Blockchain, Universidad Bernardo O'Higgins.
Integrantes: Branco Merino Huerta., Matías Díaz Zamora.

Módulo de verificación y enlace: responde si un documento corresponde a un título válido.

## Contenido

- `contracts/moduloC/VerificadorUBO.sol`: `verificar` (función `view`). Orden de comprobación: Inexistente, EmisorNoAutorizado (fecha de emisión), Revocado, Suspendido, DocumentoAlterado, Valido.
- `contracts/moduloC/HerramientasSello.sol`: `byteAceptado`, `simboloDe` y `derivarLocalizador` (localizador de 10 símbolos `[0-9A-Z]` sin sesgo de módulo) y `raizDeMerkle` (raíz de una ceremonia con pares ordenados).
- `contracts/moduloC/AnclajeLotes.sol`: `anclarLote` y `verificarInclusion` (modo económico: una raíz de Merkle por ceremonia).
- `docs/`: informes de los Hitos 1 y 2.

## Estado

| Hito | Contenido | Estado |
|---|---|---|
| 1 | `verificar`, `byteAceptado`, `simboloDe`, `derivarLocalizador` | Entregado |
| 2 | `AnclajeLotes`, `raizDeMerkle` | Entregado |
| 3 | `verificarConExplicacion`, seguridad del enlace | Pendiente |

## Cómo probarlo

1. En https://app.remix.live, clonar `https://github.com/ser-web/sello-libertador`.
2. Reemplazar los tres archivos de `contracts/moduloC/` y el archivo `tests/ModuloC_test.sol` por los de este repositorio.
3. Ajustes: compilador 0.8.20, EVM default, optimización 200, *Generate contract metadata* activado, entorno Remix VM.
4. Ejecutar `tests/ModuloC_test.sol`. En el Hito 2 pasan 5 pruebas (*Veredicto valido*, *Documento alterado un caracter*, *Lote y pruebas de inclusion*, *Localizador sin sesgo* y *Raiz de merkle en solidity*); las otras 3 fallan con TODO, como se espera.

Las carpetas `interfaces`, `comun`, `simulacros` y `scripts` son del repositorio del curso y no se incluyen aquí.
