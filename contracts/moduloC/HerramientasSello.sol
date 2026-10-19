// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IHerramientasSello.sol";
import "../comun/ConstantesUBO.sol";

/// @title HerramientasSello — PLANTILLA del Módulo C (Curso C)
/// @notice Cálculos auxiliares en Solidity. Todas las funciones son `pure`: se pueden
///         llamar gratis desde «Deploy & Run» de Remix, sin enviar transacciones.
/// @dev    Completar los TODO. Las tres últimas funciones ya están hechas.
contract HerramientasSello is IHerramientasSello {
    error ByteNoAceptado(uint8 b);
    error ListaVacia();

    /// @dev Los 36 símbolos permitidos, en orden. ALFABETO[i] devuelve el símbolo número i.
    bytes internal constant ALFABETO = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    // ---------------------------------------------------------------
    // Localizador sin sesgo de módulo
    // ---------------------------------------------------------------
    function byteAceptado(uint8 b) public pure override returns (bool) {
        // 256 = 7 x 36 + 4, el mayor múltiplo de 36 que cabe es 252.
        // Se aceptan los bytes 0..251.
        return b < 252;
    }

    function simboloDe(uint8 b) public pure override returns (bytes1) {
        // TODO: revertir con ByteNoAceptado si el byte no es aceptado
        // TODO: devolver el símbolo que corresponde al resto de dividir b por 36
        if (!byteAceptado(b)) revert ByteNoAceptado(b);
        return ALFABETO[b % 36];
    }

    function derivarLocalizador(bytes32 semilla) external pure override returns (bytes10) {
        bytes memory resultado = new bytes(10);
        uint cantidad = 0;

        // TODO: seguir el procedimiento descrito en la interfaz:
        // 1. h = keccak256(abi.encode(semilla))
        bytes32 h = keccak256(abi.encode(semilla));

        while (cantidad < 10) {
            // 2. recorrer los 32 bytes de h en orden
            for (uint256 i = 0; i < 32; i++) {
                uint8 b = uint8(h[i]);
                // 3. si el byte es aceptado, añadir su símbolo; si no, descartarlo
                if (byteAceptado(b)) {
                    resultado[cantidad] = simboloDe(b);
                    cantidad++;
                    // 5. al tener 10 símbolos, dejar de recorrer
                    if (cantidad == 10) break;
                }
            }
            // 4. si se acabaron los 32 bytes y faltan símbolos: h = keccak256(abi.encode(h))
            if (cantidad < 10) {
                h = keccak256(abi.encode(h));
            }
        }
        return bytes10(resultado);
    }

    // ---------------------------------------------------------------
    // Raíz de Merkle
    // ---------------------------------------------------------------
    function raizDeMerkle(bytes32[] calldata hojas) external pure override returns (bytes32) {
        uint256 n = hojas.length;
        if (n == 0) revert ListaVacia();

        // Copiar las hojas a memoria (calldata no se puede modificar)
        bytes32[] memory nivel = new bytes32[](n);
        for (uint256 i = 0; i < n; i++) {
            nivel[i] = hojas[i];
        }

        // Reducir nivel a nivel, en el mismo arreglo
        while (n > 1) {
            uint256 pares = n / 2;
            for (uint256 i = 0; i < pares; i++) {
                nivel[i] = _hashPar(nivel[2 * i], nivel[2 * i + 1]);
            }
            // Si el nivel es impar, el ultimo nodo sube sin emparejar
            if (n % 2 == 1) {
                nivel[pares] = nivel[n - 1];
            }
            n = pares + (n % 2);
        }
        return nivel[0];
    }

    /// @dev Hash de un par ordenado, igual que MerkleProof de OpenZeppelin. YA HECHA.
    function _hashPar(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }

    // ---------------------------------------------------------------
    // Funciones YA HECHAS (no modificar)
    // ---------------------------------------------------------------
    function hashDocumento(string calldata documentoCanonico) external pure override returns (bytes32) {
        return keccak256(bytes(documentoCanonico));
    }

    function compromiso(bytes32 sal, bytes32 hashDoc) external pure override returns (bytes32) {
        return ConstantesUBO.compromiso(sal, hashDoc);
    }

    function hojaLote(bytes10 localizador, bytes32 compromiso_) external pure override returns (bytes32) {
        return ConstantesUBO.hojaLote(localizador, compromiso_);
    }
}
