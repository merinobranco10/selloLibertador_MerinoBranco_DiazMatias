// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "remix_tests.sol";
import "../contracts/moduloC/VerificadorUBO.sol";
import "../contracts/moduloC/AnclajeLotes.sol";
import "../contracts/moduloC/HerramientasSello.sol";
import "../contracts/simulacros/SimRegistroEmisores.sol";
import "../contracts/simulacros/SimRegistroTitulos.sol";
import "../contracts/comun/ConstantesUBO.sol";

/// @title Pruebas del Módulo C — PLANTILLA (Curso C)
/// @notice Usa SimRegistroEmisores y SimRegistroTitulos en lugar de los módulos reales.
///         Mínimo 8 pruebas. Dos están resueltas como ejemplo; completar el resto.
contract ModuloCTest {
    SimRegistroEmisores registro;
    SimRegistroTitulos titulos;
    VerificadorUBO verificador;
    AnclajeLotes anclaje;
    HerramientasSello herramientas;
    address emisorIng = address(0xB1);
    bytes10 constant L1 = bytes10("U0ZSA8QPFN");
    bytes32 constant SAL_ = bytes32(uint256(111));
    bytes32 constant HASH_DOC = keccak256('{"programa":"ING-INFORMATICA"}');

    function beforeEach() public {
        registro = new SimRegistroEmisores();
        titulos = new SimRegistroTitulos();
        verificador = new VerificadorUBO(address(titulos), address(registro));
        anclaje = new AnclajeLotes(address(registro));
        herramientas = new HerramientasSello();
    }

    /// @dev Fabrica un título con el simulacro: emitido por emisorIng hace 100 s,
    ///      con un periodo de autorización que lo cubre.
    function _tituloValido(bytes10 loc) internal returns (bytes32 compromiso) {
        compromiso = ConstantesUBO.compromiso(SAL_, HASH_DOC);
        uint64 fecha = uint64(block.timestamp - 100);
        registro.fijarPeriodo(emisorIng, ConstantesUBO.ING, fecha - 1000, 0);
        titulos.fijarTitulo(loc, IRegistroTitulos.Titulo({
            compromiso: compromiso,
            emisor: emisorIng,
            facultad: ConstantesUBO.ING,
            codigoPrograma: keccak256("ING-INFORMATICA"),
            fechaEmision: fecha,
            estado: IRegistroTitulos.Estado.Emitido,
            motivo: 0,
            rectificadoComo: bytes10(0)
        }));
    }

    /// @dev Auxiliares de las pruebas de Merkle y de sesgo.
    function _par(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }

    /// @dev Posicion (0..35) de un simbolo en "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".
    function _indiceDe(bytes1 s) internal pure returns (uint256) {
        if (s >= 0x30 && s <= 0x39) return uint8(s) - 48; // '0'..'9'
        return uint8(s) - 55;                              // 'A'(65) -> 10
    }

    // ---------- EJEMPLO 1 (resuelto) ----------
    function veredictoValido() public {
        bytes32 c = _tituloValido(L1);
        Assert.equal(uint256(verificador.verificar(L1, c)),
            uint256(IVerificadorUBO.Veredicto.Valido), "Debe ser valido");
    }

    // ---------- EJEMPLO 2 (resuelto) ----------
    function documentoAlteradoUnCaracter() public {
        _tituloValido(L1);
        bytes32 alterado = ConstantesUBO.compromiso(SAL_, keccak256('{"programa":"ING-INFORMATICB"}'));
        Assert.equal(uint256(verificador.verificar(L1, alterado)),
            uint256(IVerificadorUBO.Veredicto.DocumentoAlterado), "Debe detectar la alteracion");
    }

    // ---------- PRUEBAS OBLIGATORIAS (completar) ----------
    function veredictosInexistenteYEmisorNoAutorizado() public {
        // TODO: un localizador nunca emitido -> Inexistente;
        //       fijarPeriodo() que empiece DESPUÉS de fechaEmision -> EmisorNoAutorizado
        Assert.ok(false, "TODO");
    }

    function veredictosRevocadoSuspendidoYOrden() public {
        // TODO: suspender -> Suspendido; revocar -> Revocado;
        //       un título revocado Y con documento alterado debe dar Revocado
        Assert.ok(false, "TODO");
    }

    function explicacionDeRectificacion() public {
        // TODO: rectificar L1 a otro localizador con el simulacro y comprobar que
        //       verificarConExplicacion(L1, ...) menciona el nuevo localizador
        Assert.ok(false, "TODO");
    }

    function loteYPruebasDeInclusion() public {
        // address(this) es el emisor: lo autorizamos en ING en el simulacro
        registro.autorizarEmisor(address(this), ConstantesUBO.ING);

        bytes10 l2 = bytes10("AAAAAAAAAA");
        bytes32 c1 = bytes32(uint256(1));
        bytes32 c2 = bytes32(uint256(2));
        bytes32 h1 = ConstantesUBO.hojaLote(L1, c1);
        bytes32 h2 = ConstantesUBO.hojaLote(l2, c2);

        bytes32[] memory hojas = new bytes32[](2);
        hojas[0] = h1;
        hojas[1] = h2;
        bytes32 raiz = herramientas.raizDeMerkle(hojas);

        uint256 loteId = anclaje.anclarLote(raiz, ConstantesUBO.ING, keccak256("CEREMONIA-1"));
        Assert.equal(loteId, 1, "El primer lote debe tener id 1");

        // Prueba correcta de la hoja 1: su hermano es h2
        bytes32[] memory p1 = new bytes32[](1);
        p1[0] = h2;
        Assert.ok(anclaje.verificarInclusion(loteId, L1, c1, p1), "La prueba correcta debe dar true");

        // Prueba falsa: compromiso que no esta en el lote
        Assert.ok(!anclaje.verificarInclusion(loteId, L1, c2, p1), "Una prueba falsa debe dar false");

        // Lote inexistente revierte
        try anclaje.verificarInclusion(99, L1, c1, p1) returns (bool) {
            Assert.ok(false, "Debia revertir con LoteInexistente");
        } catch {
            Assert.ok(true, "ok");
        }

        // Raiz repetida revierte
        try anclaje.anclarLote(raiz, ConstantesUBO.ING, keccak256("CEREMONIA-2")) returns (uint256) {
            Assert.ok(false, "Debia revertir con RaizDuplicada");
        } catch {
            Assert.ok(true, "ok");
        }

        // Raiz vacia revierte
        try anclaje.anclarLote(bytes32(0), ConstantesUBO.ING, keccak256("CEREMONIA-3")) returns (uint256) {
            Assert.ok(false, "Debia revertir con RaizInvalida");
        } catch {
            Assert.ok(true, "ok");
        }

        // Emisor no autorizado en esa facultad (solo esta autorizado en ING)
        try anclaje.anclarLote(bytes32(uint256(777)), ConstantesUBO.SAL, keccak256("CEREMONIA-4")) returns (uint256) {
            Assert.ok(false, "Debia revertir con NoAutorizado");
        } catch {
            Assert.ok(true, "ok");
        }
    }

    function localizadorSinSesgo() public {
        // (a) Prueba por enumeracion: los 36 contadores deben valer lo mismo (7)
        uint256[36] memory cont;
        for (uint256 b = 0; b < 256; b++) {
            if (herramientas.byteAceptado(uint8(b))) {
                cont[_indiceDe(herramientas.simboloDe(uint8(b)))]++;
            }
        }
        for (uint256 i = 0; i < 36; i++) {
            Assert.equal(cont[i], 7, "Cada simbolo debe recibir exactamente 7 bytes");
        }

        // (b) derivarLocalizador: 10 simbolos validos, determinista, cambia con la semilla
        bytes10 a = herramientas.derivarLocalizador(bytes32(uint256(1)));
        bytes10 a2 = herramientas.derivarLocalizador(bytes32(uint256(1)));
        bytes10 b2 = herramientas.derivarLocalizador(bytes32(uint256(2)));
        Assert.ok(a == a2, "La misma semilla debe dar el mismo localizador");
        Assert.ok(a != b2, "Otra semilla debe dar otro localizador");
        for (uint256 i = 0; i < 10; i++) {
            bytes1 ch = a[i];
            bool ok = (ch >= 0x30 && ch <= 0x39) || (ch >= 0x41 && ch <= 0x5A);
            Assert.ok(ok, "Cada caracter debe estar en [0-9A-Z]");
        }
    }

    function raizDeMerkleEnSolidity() public {
        bytes32 h1 = bytes32(uint256(11));
        bytes32 h2 = bytes32(uint256(22));
        bytes32 h3 = bytes32(uint256(33));

        // 1 hoja: la raiz es la propia hoja
        bytes32[] memory una = new bytes32[](1);
        una[0] = h1;
        Assert.equal(herramientas.raizDeMerkle(una), h1, "Con 1 hoja la raiz es la hoja");

        // 2 hojas
        bytes32[] memory dos = new bytes32[](2);
        dos[0] = h1;
        dos[1] = h2;
        Assert.equal(herramientas.raizDeMerkle(dos), _par(h1, h2), "Raiz de 2 hojas");

        // 3 hojas: par(par(h1,h2), h3); el ultimo sube sin emparejar
        bytes32[] memory tres = new bytes32[](3);
        tres[0] = h1;
        tres[1] = h2;
        tres[2] = h3;
        Assert.equal(herramientas.raizDeMerkle(tres), _par(_par(h1, h2), h3), "Raiz de 3 hojas");

        // 0 hojas: revierte
        bytes32[] memory vacia = new bytes32[](0);
        try herramientas.raizDeMerkle(vacia) returns (bytes32) {
            Assert.ok(false, "Debia revertir con ListaVacia");
        } catch {
            Assert.ok(true, "ok");
        }
    }
}
