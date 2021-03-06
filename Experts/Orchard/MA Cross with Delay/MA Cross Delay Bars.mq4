/*

   MA Cross Delay Bars.mq4
   Copyright 2022, Orchard Forex
   https://www.orchardforex.com

*/

/**=
 *
 * Disclaimer and Licence
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * All trading involves risk. You should have received the risk warnings
 * and terms of use in the README.MD file distributed with this software.
 * See the README.MD file for more information and before using this software.
 *
 **/

#property copyright "Copyright 2022, Orchard Forex"
#property link "https://www.orchardforex.com"
#property version "1.00"
#property strict

// Inputs
input int    InpFastPeriod   = 10;         // fast ma period
input int    InpSlowPeriod   = 50;         // slow ma period
input double InpLotSize      = 0.01;       // lot size
input int    InpMagic        = 222222;     // magic number
input string InpTradeComment = "MA Cross"; // Trade comment

input int    InpDelayBars    = 12; // delay between trades in bars

datetime     LastTradeTime   = 0;

int          OnInit() {

   return ( INIT_SUCCEEDED );
}

void OnDeinit( const int reason ) {
}

void OnTick() {

   //	Comparing current bar to bar 1 for demonstration
   double fast1 = iMA( Symbol(), Period(), InpFastPeriod, 0, MODE_SMA, PRICE_CLOSE, 0 );
   double fast2 = iMA( Symbol(), Period(), InpFastPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );
   double slow1 = iMA( Symbol(), Period(), InpSlowPeriod, 0, MODE_SMA, PRICE_CLOSE, 0 );
   double slow2 = iMA( Symbol(), Period(), InpSlowPeriod, 0, MODE_SMA, PRICE_CLOSE, 1 );

   UpdateTrailingStop();                        //	Nothing here yet
   CloseOnCondition();                          //	Nothing here yet
   if ( fast1 > slow1 && !( fast2 > slow2 ) ) { // crossed up
      TradeOpen( ORDER_TYPE_BUY );
   }
   else if ( fast1 < slow1 && !( fast2 < slow2 ) ) { // crossed down
      TradeOpen( ORDER_TYPE_SELL );
   }
}

bool TradeOpen( ENUM_ORDER_TYPE type ) {

   if ( iBarShift( Symbol(), Period(), LastTradeTime, false ) < InpDelayBars ) return ( false );

   //	For the example I'm ignoring possible errors on new orders
   double price = ( type == ORDER_TYPE_BUY ) ? SymbolInfoDouble( Symbol(), SYMBOL_ASK )
                                             : SymbolInfoDouble( Symbol(), SYMBOL_BID );
   bool   result =
      ( OrderSend( Symbol(), type, InpLotSize, price, 0, 0, 0, InpTradeComment, InpMagic ) > 0 );
   if ( result ) {
      LastTradeTime = TimeCurrent();
   }

   return ( result );
}

void CloseOnCondition() {

   //	Nothing here
}

void UpdateTrailingStop() {

   //	Nothing here
}
