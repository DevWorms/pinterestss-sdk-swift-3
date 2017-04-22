//
//  Errores.swift
//  MenuDeslizante
//
//  Created by sergio ivan lopez monzon on 10/12/16.
//  Copyright © 2016 sergio ivan lopez monzon. All rights reserved.
//

import Foundation


open class Errores{
    
    func getError(_ errorCode:String) -> String{
    
        var mensaje = "";
    
        switch (errorCode){
            case "1000":	mensaje = "Internal Server Error Ocurrió un error interno en el servidor de Openpay"
            
            
            case "1001":	mensaje = "El formato de la petición no es JSON, los campos no tienen el formato correcto, o la petición no tiene campos que son requeridos"
            
            case "1002":	mensaje = "La llamada no esta autenticada o la autenticación es incorrecta"
            case "1003":	mensaje = "422 Unprocessable Entity La operación no se pudo completar por que el valor de uno o más de los parametros no es correcto"
            
            case "1004":	mensaje = "Un servicio necesario para el procesamiento de la transacción no se encuentra disponible"
            case "1005":	mensaje = "Uno de los recursos requeridos no existe"
            case "1006":	mensaje = "Ya existe una transacción con el mismo ID de orden"
            case "1007":	mensaje = "Por el momento no puede darse de baja la tarjeta ya que se esta usando en una suscripcion, de de baja primero la suscricpion y luego elimine la tarjeta"
            case "1008":	mensaje = "Una de las cuentas requeridas en la petición se encuentra desactivada"
            case "1009":	mensaje = "El cuerpo de la petición es demasiado grande"
            case "1010":	mensaje = "Se esta utilizando la llave pública para hacer una llamada que requiere la llave privada, o bien, se esta usando la llave privada desde JavaScript"
    
            case "2001":	mensaje = "La cuenta de banco con esta CLABE ya se encuentra registrada en el cliente"
            case "2002":	mensaje = "La tarjeta con este número ya se encuentra registrada en el cliente"
            case "2003":	mensaje = "El cliente con este identificador externo (External ID) ya existe"
            case "2004":	mensaje = "El dígito verificador del número de tarjeta es inválido de acuerdo al algoritmo Luhn"
            case "2005":	mensaje = "La fecha de expiración de la tarjeta es anterior a la fecha actual"
            case "2006":	mensaje = "El código de seguridad de la tarjeta (CVV2) no fue proporcionado"
            case "2007":	mensaje = "El número de tarjeta es de prueba, solamente puede usarse en Sandbox"
            case "2008":	mensaje = "La tarjeta consultada no es valida para puntos"
    
            case "3001":    mensaje = "La tarjeta fue declinada"
            case "3002":    mensaje = "La tarjeta ha expirado"
            case "3003":	mensaje = "La tarjeta no tiene fondos suficientes"
            case "3004":	mensaje = "La tarjeta ha sido identificada como una tarjeta robada"
            case "3005":	mensaje = "La tarjeta ha sido identificada como una tarjeta fraudulenta"
            case "3006":	mensaje = "La operación no esta permitida para este cliente o esta transacción"
            case "3008":	mensaje = "La tarjeta no es soportada en transacciones en linea"
            case "3009":	mensaje = "La tarjeta fue reportada como perdida"
            case "3010":	mensaje = "El banco ha restringido la tarjeta"
            case "3011":	mensaje = "El banco ha solicitado que la tarjeta sea retenida. Contacte al banco"
            case "3012":	mensaje = "Se requiere solicitar al banco autorización para realizar este pago"
    
            case "4001":	mensaje = "La cuenta de Openpay no tiene fondos suficientes"
            
        default:
            mensaje = "error"
        }
    
        return mensaje
    }
}
