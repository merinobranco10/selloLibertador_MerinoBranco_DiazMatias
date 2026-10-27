// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IVerificadorUBO.sol";
import "../interfaces/IRegistroTitulos.sol";
import "../interfaces/IRegistroEmisores.sol";

/// @title VerificadorUBO — PLANTILLA del Módulo C (Curso C)
/// @notice Aplica la regla RN-06 y devuelve un veredicto.
/// @dev    Completar los TODO. Orden OBLIGATORIO (el primero que falla decide):
///         1) Inexistente  2) EmisorNoAutorizado (en la FECHA DE EMISIÓN)
///         3) Revocado     4) Suspendido   5) DocumentoAlterado   6) Valido
contract VerificadorUBO is IVerificadorUBO {
    IRegistroTitulos public immutable titulos;
    IRegistroEmisores public immutable registro;

    constructor(address titulos_, address registro_) {
        titulos = IRegistroTitulos(titulos_);
        registro = IRegistroEmisores(registro_);
    }

    function verificar(bytes10 localizador, bytes32 compromisoRecalculado)
        external
        view
        override
        returns (Veredicto)
    {
        IRegistroTitulos.Titulo memory t = titulos.obtenerTitulo(localizador);

        // 1) Inexistente
        if (t.estado == IRegistroTitulos.Estado.Inexistente) {
            return Veredicto.Inexistente;
        }

        // 2) Emisor no autorizado EN LA FECHA DE EMISIÓN (función histórica)
        if (!registro.estabaAutorizado(t.emisor, t.facultad, t.fechaEmision)) {
            return Veredicto.EmisorNoAutorizado;
        }

        // 3) Revocado
        if (t.estado == IRegistroTitulos.Estado.Revocado) {
            return Veredicto.Revocado;
        }

        // 4) Suspendido
        if (t.estado == IRegistroTitulos.Estado.Suspendido) {
            return Veredicto.Suspendido;
        }

        // 5) Documento alterado
        if (t.compromiso != compromisoRecalculado) {
            return Veredicto.DocumentoAlterado;
        }

        // 6) Válido
        return Veredicto.Valido;
    }   


    /// @notice Versión explicativa para el verificador humano.
    /// @dev    OBLIGATORIA: devuelve el veredicto y un texto claro en español
    ///         para un empleador, p. ej. "Titulo valido emitido por la UBO".
    ///         Si el título fue rectificado, la explicación debe indicar el nuevo localizador
    ///         (campo rectificadoComo) para que el empleador pida el documento correcto.
    function verificarConExplicacion(bytes10 localizador, bytes32 compromisoRecalculado)
        external
        view
        returns (Veredicto veredicto, string memory explicacion)
    {
    // Obtener el veredicto usando la lógica del verificador.
        veredicto = this.verificar(localizador, compromisoRecalculado);
        if (veredicto == Veredicto.Valido) {
            explicacion = "El titulo es valido.";
            return (veredicto, explicacion);
            } 
        if (veredicto == Veredicto.Revocado) {
            IRegistroTitulos.Titulo memory titulo =
                titulos.obtenerTitulo(localizador);

            if (titulo.rectificadoComo != bytes10(0)) {
                bytes memory nuevoLocalizador = new bytes(10);
                for (uint256 i = 0; i < 10; i++) {
                    nuevoLocalizador[i] = titulo.rectificadoComo[i];
                    }
                    explicacion = string.concat(
                        "El titulo fue rectificado. Nuevo localizador: ",
                        string(nuevoLocalizador)
                    );
                    return (veredicto, explicacion);
            } else {
                explicacion = "El titulo fue revocado.";
                }
            return (veredicto, explicacion);
            }
        if (veredicto == Veredicto.Suspendido) {
            explicacion = "El titulo esta suspendido.";
            return (veredicto, explicacion);
            } 
        if (veredicto == Veredicto.Inexistente) {
            explicacion = "No existe un titulo con ese localizador.";
            return (veredicto, explicacion);
            } 
        if (veredicto == Veredicto.EmisorNoAutorizado) {
            explicacion = "El emisor no estaba autorizado en la fecha de emision.";
            return (veredicto, explicacion);
            } 
        if (veredicto == Veredicto.DocumentoAlterado) {
            explicacion = "El documento no coincide con el compromiso registrado.";
            return (veredicto, explicacion);
            }
    }
}
