# Sello Libertador: Bloque 3 (Módulo C)

Criptografía y Blockchain, Universidad Bernardo O'Higgins.
Integrantes: Branco Merino Huerta., Matías Díaz Zamora.

Módulo de verificación y enlace: responde si un documento corresponde a un título válido.

## Contenido

- `contracts/moduloC/VerificadorUBO.sol`: `verificar` (función `view`). Orden de comprobación: Inexistente, EmisorNoAutorizado (fecha de emisión), Revocado, Suspendido, DocumentoAlterado, Valido.
- `contracts/moduloC/VerificadorUBO.sol` (Hito 3): `verificarConExplicacion` (función `view`). Reutiliza `verificar` y devuelve el veredicto con un texto claro para un empleador; si el título fue rectificado, el texto indica el nuevo localizador.
- `contracts/moduloC/HerramientasSello.sol`: `byteAceptado`, `simboloDe` y `derivarLocalizador` (localizador de 10 símbolos `[0-9A-Z]` sin sesgo de módulo) y `raizDeMerkle` (raíz de una ceremonia con pares ordenados).
- `contracts/moduloC/AnclajeLotes.sol`: `anclarLote` y `verificarInclusion` (modo económico: una raíz de Merkle por ceremonia).
- `docs/`: informes de los Hitos 1, 2 y 3.

## Estado

| Hito | Contenido | Estado |
|---|---|---|
| 1 | `verificar`, `byteAceptado`, `simboloDe`, `derivarLocalizador` | Entregado |
| 2 | `AnclajeLotes`, `raizDeMerkle` | Entregado |
| 3 | `verificarConExplicacion`, seguridad del enlace | Entregado |

## **Gas, modo económico frente a completo:**

| Ceremonia | Modo económico | Modo completo (simulacro) |
|---|---|---|
| 8 títulos | 149.219 | 8 × 137.212 = 1.097.696 |
| 50 títulos | 149.231 | 50 × 137.212 = 6.860.600 |

  Anclar cuesta casi lo mismo sin importar el tamaño de la ceremonia, porque solo guarda una raíz; se renuncia al estado por título.
- **Anular un título en modo económico:** con una lista de revocación aparte que el verificador consulta además de la prueba de inclusión, ya que en este modo el título no existe en `RegistroTitulos` y `revocar` no aplica. Se compara con re-anclar la ceremonia sin ese título y con registrar solo las excepciones (detalle en el informe del Hito 3).
  
## Cómo probarlo

1. En https://app.remix.live, clonar `https://github.com/ser-web/sello-libertador`.
2. Reemplazar los tres archivos de `contracts/moduloC/` y el archivo `tests/ModuloC_test.sol` por los de este repositorio.
3. Ajustes: compilador 0.8.20, EVM default, optimización 200, *Generate contract metadata* activado, entorno Remix VM.
4. Ejecutar `tests/ModuloC_test.sol`. En el Hito 2 pasan 5 pruebas (*Veredicto valido*, *Documento alterado un caracter*, *Lote y pruebas de inclusion*, *Localizador sin sesgo* y *Raiz de merkle en solidity*); las otras 3 fallan con TODO, como se espera.
5. Hito 3: pasan las 8 pruebas. Se suman *Veredictos inexistente y emisor no autorizado*, *Veredictos revocado suspendido y orden* y *Explicacion de rectificacion*.

Las carpetas `interfaces`, `comun`, `simulacros` y `scripts` son del repositorio del curso y no se incluyen aquí.
