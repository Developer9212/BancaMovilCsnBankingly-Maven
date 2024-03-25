/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package consumo_tdd;

import com.syc.ws.endpoint.siscoop.BalanceQueryResponseDto;

/**
 *
 * @author sistemas
 */
public class main {
    public static void main(String[] args) {
        Siscoop_TDD service_tdd=new Siscoop_TDD("ws_sanNico", "wZ4XTX8GmNh", "200.15.1.143","8080","siscoopAlternativeService");
        BalanceQueryResponseDto responseTDD= new BalanceQueryResponseDto();
        responseTDD=service_tdd.getSiscoop().getBalanceQuery("5062470101246733");
        System.out.println("Saldo en tdd:"+responseTDD.getAvailableAmount());
    }
}
