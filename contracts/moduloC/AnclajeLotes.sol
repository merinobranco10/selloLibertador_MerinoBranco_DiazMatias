// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.1.0/utils/cryptography/MerkleProof.sol";
import "../interfaces/IAnclajeLotes.sol";
import "../interfaces/IRegistroEmisores.sol";
import "../comun/ConstantesUBO.sol";

/// @title AnclajeLotes — PLANTILLA del Módulo C (Curso C)
/// @notice MODO ECONÓMICO, alternativo a RegistroTitulos: ancla la raíz de Merkle de una
///         ceremonia completa en UNA transacción, sin guardar cada título en la cadena.
///         No se usa sobre los mismos títulos que ya están en RegistroTitulos: es otra
///         forma de emitir, más barata y con menos funciones (no hay estado por título).
/// @dev    Completar los TODO. Requisitos mínimos:
///         - Solo emisores autorizados AHORA en la facultad.
///         - Rechazar raíz vacía y raíces repetidas.
///         - Hoja = ConstantesUBO.hojaLote(localizador, compromiso).
///         - Verificación con MerkleProof.verify (pares ordenados).
contract AnclajeLotes is IAnclajeLotes {
    error NoAutorizado(address cuenta, bytes32 facultad);
    error RaizInvalida();
    error RaizDuplicada(bytes32 raiz);
    error LoteInexistente(uint256 loteId);

    struct Lote {
        bytes32 raiz;
        bytes32 facultad;
        bytes32 idCeremonia;
        address emisor;
        uint64 fecha;
    }

    IRegistroEmisores public immutable registro;
    mapping(uint256 => Lote) private _lotes;
    mapping(bytes32 => bool) private _raizUsada;
    uint256 private _siguienteId = 1;

    constructor(address registro_) {
        registro = IRegistroEmisores(registro_);
    }

    function anclarLote(bytes32 raiz, bytes32 facultad, bytes32 idCeremonia)
        external
        override
        returns (uint256 loteId)
    {
        // 1) Solo un emisor autorizado AHORA en la facultad
        if (!registro.estaAutorizado(msg.sender, facultad)) {
            revert NoAutorizado(msg.sender, facultad);
        }
        // 2) Validaciones: raiz no vacia y no repetida
        if (raiz == bytes32(0)) revert RaizInvalida();
        if (_raizUsada[raiz]) revert RaizDuplicada(raiz);

        // 3) Efectos: marcar la raiz, guardar el lote (los ids empiezan en 1)
        loteId = _siguienteId++;
        _raizUsada[raiz] = true;
        _lotes[loteId] = Lote({
            raiz: raiz,
            facultad: facultad,
            idCeremonia: idCeremonia,
            emisor: msg.sender,
            fecha: uint64(block.timestamp)
        });

        // 4) Evento
        emit LoteAnclado(loteId, facultad, raiz, idCeremonia, msg.sender);
    }

    function verificarInclusion(
        uint256 loteId,
        bytes10 localizador,
        bytes32 compromiso,
        bytes32[] calldata prueba
    ) external view override returns (bool) {
        bytes32 raiz = _lotes[loteId].raiz;
        // Un lote existente nunca tiene raiz cero (anclarLote la rechaza)
        if (raiz == bytes32(0)) revert LoteInexistente(loteId);

        bytes32 hoja = ConstantesUBO.hojaLote(localizador, compromiso);
        return MerkleProof.verifyCalldata(prueba, raiz, hoja);
    }

    function obtenerLote(uint256 loteId) external view returns (Lote memory) {
        return _lotes[loteId];
    }
}
