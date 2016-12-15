open Yojson.Basic

type env =
  { currentCoinbase : string
  ; currentDifficulty : string
  ; currentGasLimit : string
  ; currentNumber : string
  ; currentTimestamp : string
  }

let parse_env (j : json) : env =
  Util.(
    { currentCoinbase = to_string (member "currentCoinbase" j)
    ; currentDifficulty = to_string (member "currentDifficulty" j)
    ; currentGasLimit = to_string (member "currentGasLimit" j)
    ; currentNumber = to_string (member "currentNumber" j)
    ; currentTimestamp = to_string (member "currentTimestamp" j)
    })

type exec =
  { address : string
  ; caller : string
  ; code : string
  ; data : string
  ; gas : string
  ; gasPrice : string
  ; origin : string
  ; value : string
  }

let parse_exec (j : json) : exec =
  Util.(
    { address = to_string (member "address" j)
    ; caller = to_string (member "caller" j)
    ; code = to_string (member "code" j)
    ; data = to_string (member "data" j)
    ; gas = to_string (member "gas" j)
    ; gasPrice = to_string (member "gasPrice" j)
    ; origin = to_string (member "origin" j)
    ; value = to_string (member "value" j)
    })

type storage = (string * string) list

let parse_storage (j : json) : storage =
  Util.(
    List.map (fun (label, content) -> (label, to_string content)) (to_assoc j)
  )

type account_state =
  { balance : string
  ; code : string
  ; nonce : string
  ; storage : storage
  }

let parse_account_state (j : json) : account_state =
  Util.(
  { balance = to_string (member "balance" j)
  ; code = to_string (member "code" j)
  ; nonce = to_string (member "nonce" j)
  ; storage = parse_storage (member "storage" j)
  })

let parse_states (asc : (string * json) list) : (string * account_state) list =
  List.map (fun (label, j) -> (label, parse_account_state j)) asc

type test_case =
  { callcreates : json list
  ; env : env
  ; exec : exec
  ; gas : string option
  ; logs : json list option
  ; out : string option
  ; post : (string * account_state) list option
  ; pre : (string * account_state) list
  }

let parse_test_case (j : json) : test_case =
  Util.(
  { callcreates =
      (try
        to_list (member "callcreates" j)
       with Yojson.Basic.Util.Type_error _ ->
        []
      )
  ; env = parse_env (member "env" j)
  ; exec = parse_exec (member "exec" j)
  ; gas =
      (try Some (to_string (member "gas" j))
       with Yojson.Basic.Util.Type_error _ -> None)
  ; logs =
      (try Some (to_list (member "logs" j))
       with Yojson.Basic.Util.Type_error _ -> None)
  ; out =
      (try Some (to_string (member "out" j))
       with Yojson.Basic.Util.Type_error _ -> None)
  ; post =
      (try
         Some (parse_states (to_assoc (member "post" j)))
       with Yojson.Basic.Util.Type_error _ ->
         None
      )
  ; pre = parse_states (to_assoc (member "pre" j))
  })

let () =
  let vm_arithmetic_test : json = Yojson.Basic.from_file "../tests/VMTests/vmArithmeticTest.json" in
  let vm_arithmetic_test_assoc : (string * json) list = Util.to_assoc vm_arithmetic_test in
  let () =
    List.iter (fun (label, elm) ->
        let () = Printf.printf "%s\n" label in
        let case : test_case = parse_test_case elm in
        ()
      ) vm_arithmetic_test_assoc in
  let vm_arithmetic_test : json = Yojson.Basic.from_file "../tests/VMTests/vmIOandFlowOperationsTest.json" in
  let vm_arithmetic_test_assoc : (string * json) list = Util.to_assoc vm_arithmetic_test in
  let () =
    List.iter (fun (label, elm) ->
        let () = Printf.printf "%s\n" label in
        let case : test_case = parse_test_case elm in
        ()
      ) vm_arithmetic_test_assoc
  in
  ()