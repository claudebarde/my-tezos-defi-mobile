type current_page =
    | Home_page
    | Tokens_page
    | Settings_page
    | Farms_page
    | Not_found_page

let ls_prefix = "mtd-"
let ls_user_address = "userAddress"

let available_tokens = ["kUSD", "hDAO", "PLENTY", "xPLENTY", "wXTZ", "STKR", "tzBTC", "USDtz", "ETHtz", "CRUNCH", "WRAP",
 "wAAVE", "wBUSD", "wCEL", "wCOMP", "wCRO", "wDAI", "wFTT", "wHT", "wHUSD", "wLEO", "wLINK", "wMATIC", "wMKR", "wOKB",
 "wPAX", "wSUSHI", "wUNI", "wUSDC", "wUSDT", "wWBTC", "wWETH", "crDAO", "FLAME", "KALAM", "PAUL", "SMAK", "GOT", "HERA",
 "kDAO", "QUIPU", "uUSD", "YOU", "Ctez", "MAG", "PXL", "pxlDAO", "fDAO", "BTCtz", "IDZ", "GIF", "TezDAO"]