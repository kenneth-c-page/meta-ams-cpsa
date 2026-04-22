(herald "Meta-AMS (MAMS) Registrar Registration")

(defprotocol mams_registrar_reg basic
    ;;; Registrar Registration and Related Processes ;;;
    (defrole new_registrar
        (vars
            (foreign_unit ar_nonce rn_nonce cs_nonce1 text) (unit venture cont name) (reg_mib locn)
        )
        (trace
            (send 
                (cat
                    unit
                    "announce_registrar"
                    ar_nonce
                    (enc
                        "announce_registrar"
                        ar_nonce
                        (privk venture)
                    )
                )
            )
            (recv
                (cat
                    "0"
                    "registrar_noted"
                    rn_nonce
                    (enc
                        "registrar_noted"
                        rn_nonce
                        (prvik cont)
                    )
                )
            )
            (recv
                (cat
                    "0"
                    "cell_spec1"
                    cs_nonce1
                    (enc
                        "cell_spec1"
                        cs_nonce1
                        (privk cont)
                    )
                    foreign_unit
                )
            )
            (stor reg_mib
                (cat "reg_mem" foreign_unit)
            )
        )
    )

    (defrole config_server_accept
        (vars
            (foreign_unit ar_nonce rn_nonce cs_nonce1 text) (unit venture cont name) (conf_mib locn)
        )
        (trace
            (recv 
                (cat
                    unit
                    "announce_registrar"
                    ar_nonce
                    (enc
                        "announce_registrar"
                        ar_nonce
                        (privk venture)
                    )
                )
            )
            (stor conf_mib
                (cat "conf_mem" unit)
            )
            (send
                (cat
                    "0"
                    "registrar_noted"
                    rn_nonce
                    (enc
                        "registrar_noted"
                        rn_nonce
                        (prvik cont)
                    )
                )
            )
            (load
                conf_mib
                (cat
                    (cat "conf_mem" foreign_unit)
                )
            )
            (send
                (cat
                    "0"
                    "cell_spec1"
                    cs_nonce1
                    (enc
                        "cell_spec1"
                        cs_nonce1
                        (privk cont)
                    )
                    foreign_unit
                )
            )
            (gen-st
                (cat "conf_mem" foreign_unit)
            )
        )
    )

    (defrole config_server_prereg
        (vars
            (hb_nonce1 hb_nonce2 text) (foreign_unit venture cont name) (conf_mib locn)
        )
        (trace
            (stor ; this information is either preloaded, sent, etc., up to implementation
                conf_mib
                (cat "conf_mem" foreign_unit)
            )
            (recv
                (cat
                    foreign_unit
                    "foreign_hearbeat"
                    hb_nonce1
                    (enc
                        "foreign_heartbeat"
                        hb_nonce1
                        (privk venture)
                    )
                )
            )
            (send
                (cat
                    "0"
                    "config_heartbeat"
                    hb_nonce2
                    (enc
                        "config_heartbeat"
                        hb_nonce2
                        (privk cont)
                    )
                )
            )
        )
    )

    (defrole foreign_registrars_hearbeat
        (vars
            (hb_nonce1 hb_nonce2 text) (foreign_unit venture cont name) (conf_mib locn)
        )
        (trace
            (send
                (cat
                    foreign_unit
                    "foreign_hearbeat"
                    hb_nonce1
                    (enc
                        "foreign_heartbeat"
                        hb_nonce1
                        (privk venture)
                    )
                )
            )
            (recv
                (cat
                    "0"
                    "config_heartbeat"
                    hb_nonce2
                    (enc
                        "config_heartbeat"
                        hb_nonce2
                        (privk cont)
                    )
                )
            )
        )
    )

    (defrole config_server_forward
        (vars
            (cs_nonce2 text) (unit cont name) (conf_mib locn)
        )
        (trace
            (load conf_mib
                (cat "conf_mem" unit)
            )
            (send
                (cat
                    "0"
                    "cell_spec2"
                    cs_nonce2
                    (enc
                        "cell_spec2"
                        cs_nonce2
                        (privk cont)
                    )
                    unit
                )
            )
        )
        (gen-st
            (cat "conf_mem" unit)
        )
    )
    
    (defrole foreign_registrars_postreg
        (vars
            (cs_nonce2 text) (unit cont name)
        )
        (trace
            (recv
                (cat
                    "0"
                    "cell_spec2"
                    cs_nonce2
                    (enc
                        "cell_spec2"
                        cs_nonce2
                        (privk cont)
                    )
                    unit
                )
            )
        )
    )
    
    (defrole registrar_rejected
        (vars
            (ar_nonce1 rr_nonce text) (reg_endpoint_name venture unit cont name)
        )
        (trace
            (send 
                (cat
                    unit
                    "announce_registrar"
                    ar_nonce1
                    (enc
                        "announce_registrar"
                        ar_nonce1
                        (privk venture)
                    )
                )
            )
            (recv
                (cat
                    "0"
                    "registrar_rejected"
                    rr_nonce
                    (enc
                        "registrar_rejected"
                        rr_nonce
                        (prvik cont)
                    )
                )
            )
        )
    )

    (defrole config_server_reject
        (vars
            (ar_nonce1 rr_nonce text) (reg_endpoint_name venture unit cont name)
        )
        (trace
            (recv 
                (cat
                    unit
                    "announce_registrar"
                    ar_nonce1
                    (enc
                        "announce_registrar"
                        ar_nonce1
                        (privk venture)
                    )
                )
            )
            (send
                (cat
                    "0"
                    "registrar_rejected"
                    rr_nonce
                    (enc
                        "registrar_rejected"
                        rr_nonce
                        (prvik cont)
                    )
                )
            )
        )
    )

    ;;; Registrar Location Preceding Module Registration ;;;
    (defrole new_module
        (vars
            (unit role_number pre_role_number venture cont foreign_unit foreign_role_number name) (rq_nonce cs_nonce3 mr_nonce yai_nonce iah_nonce mod_num pre_mod_num iah_nonce2 foreign_mod_num text) (module_mib locn)
        )
        (trace
            (send
                (cat
                    unit
                    role_number
                    "registrar_query"
                    rq_nonce
                    (enc
                        "registrar_query"
                        rq_nonce
                        (privk role_number)
                    )
                )
            )
            (recv
                (cat
                    "0"
                    "cell_spec3"
                    cs_nonce3
                    (enc
                        "cell_spec3"
                        cs_nonce3
                        (privk cont)
                    )
                    unit
                )
            )
            (stor module_mib
                (cat "mod_mem" unit)
            )
            (send
                (cat
                    unit
                    role_number
                    "module_registration"
                    mr_nonce
                    (enc
                        "module_registration"
                        mr_nonce
                        (privk role_number)
                    )
                )
            )
            (recv
                (cat
                    unit
                    "you_are_in"
                    yai_nonce
                    mod_num
                    (enc
                        "you_are_in"
                        yai_nonce
                        (privk venture)
                    )
                )
            )
            (stor module_mib
                (cat "mod_mem" mod_num)
            )
            (recv
                (cat
                    unit
                    pre_role_number
                    "i_am_here"
                    iah_nonce
                    pre_mod_num
                    (enc
                        "i_am_here"
                        iah_nonce
                        (privk pre_role_number)
                    )
                )
            )
            (stor module_mib
                (cat "mod_mem" unit pre_role_number pre_mod_num)
            )
            (recv
                (cat
                    foreign_unit
                    foreign_role_number
                    "i_am_here2"
                    iah_nonce2
                    foreign_mod_num
                    (enc
                        "i_am_here2"
                        iah_nonce2
                        (privk foreign_role_number)
                    )
                )
            )
            (stor module_mib
                (cat "mod_mem" foreign_unit foreign_role_number foreign_mod_num)
            )
        )
    )

    (defrole config_server_known
        (vars
            (unit role_number cont name) (rq_nonce cs_nonce3 text) (conf_mib locn)
        )
        (trace
            (recv
                (cat
                    unit
                    role_number
                    "registrar_query"
                    rq_nonce
                    (enc
                        "registrar_query"
                        rq_nonce
                        (privk role_number)
                    )
                )
            )
            (load conf_mib
                (cat "conf_mem" unit)
            )
            (send
                (cat
                    "0"
                    "cell_spec3"
                    cs_nonce3
                    (enc
                        "cell_spec3"
                        cs_nonce3
                        (privk cont)
                    )
                    unit
                )
            )
        )
        (gen-st
            (cat "conf_mem" unit)
        )
    )

    (defrole config_server_unknown
        (vars
            (unit1 role_number1 cont name) (rq_nonce1 ru_nonce text)
        )
        (trace
            (recv
                (cat
                    unit1
                    role_number1
                    "registrar_query"
                    rq_nonce1
                    (enc
                        "registrar_query"
                        rq_nonce1
                        (privk role_number1)
                    )
                )
            )
            (send
                (cat
                    "0"
                    "registrar_unknown"
                    ru_nonce
                    (enc
                        "registrar_unknown"
                        ru_nonce
                        (privk cont)
                    )
                )
            )
        )
    )

    (defrole new_module_unknown
        (vars
            (unit1 role_number1 cont name) (rq_nonce1 ru_nonce text)
        )
        (trace
            (send
                (cat
                    unit1
                    role_number1
                    "registrar_query"
                    rq_nonce1
                    (enc
                        "registrar_query"
                        rq_nonce1
                        (privk role_number1)
                    )
                )
            )
            (recv
                (cat
                    "0"
                    "registrar_unknown"
                    ru_nonce
                    (enc
                        "registrar_unknown"
                        ru_nonce
                        (privk cont)
                    )
                )
            )
        )
    )

    (defrole registrar_mod_reg
        (vars
            (unit role_number venture name) (mod_num mr_nonce yai_nonce ias_nonce text) (reg_mib locn)
        )
        (trace
            (recv
                (cat
                    unit
                    role_number
                    "module_registration"
                    mr_nonce
                    (enc
                        "module_registration"
                        mr_nonce
                        (privk role_number)
                    )
                )
            )
            (send
                (cat
                    unit
                    "you_are_in"
                    yai_nonce
                    mod_num
                    (enc
                        "you_are_in"
                        yai_nonce
                        (privk venture)
                    )
                )
            )
            (send
                (cat
                    unit
                    role_number
                    "i_am_starting"
                    ias_nonce
                    mod_num
                    (enc
                        "i_am_starting"
                        ias_nonce
                        (privk venture)
                    )
                )
            )
            (stor reg_mib
                (cat "reg_mem" mod_num)
            )
        )
    )

    (defrole preexising_module
        (vars
            (unit role_number venture pre_role_number name) (ias_nonce mod_num pre_mod_num iah_nonce text) (pre_mod_mib locn)
            (rr_role_number name) (ias_nonce1 iah_nonce1 mod_num1 text)
            (mhs_nonce alt_mod_num text)
        )
        (trace
            (recv
                (cat
                    unit
                    role_number
                    "i_am_starting"
                    ias_nonce
                    mod_num
                    (enc
                        "i_am_starting"
                        ias_nonce
                        (privk venture)
                    )
                )
            )
            (stor pre_mod_mib
                (cat "mod_mem" unit role_number mod_num)
            )
            (load pre_mod_mib
                (cat "mod_mem" pre_mod_num)
            )
            (send
                (cat
                    unit
                    pre_role_number
                    "i_am_here"
                    iah_nonce
                    pre_mod_num
                    (enc
                        "i_am_here"
                        iah_nonce
                        (privk pre_role_number)
                    )
                )
            )

            (recv
                (cat
                    unit
                    rr_role_number
                    "i_am_starting1"
                    ias_nonce1
                    mod_num1
                    (enc
                        "i_am_starting1"
                        ias_nonce1
                        (privk venture)
                    )
                )
            )
            (stor pre_mod_mib
                (cat "mod_mem" unit rr_role_number mod_num1)
            )
            (send
                (cat
                    unit
                    pre_role_number
                    "i_am_here1"
                    iah_nonce1
                    pre_mod_num
                    (enc
                        "i_am_here1"
                        iah_nonce1
                        (privk pre_role_number)
                    )
                )
            )

            (recv
                (cat
                    unit
                    "module_has_started"
                    mhs_nonce
                    alt_mod_num
                    (enc
                        "module_has_started"
                        mhs_nonce
                        (privk venture)
                    )
                )
            )
            (stor pre_mod_mib
                (cat "mod_mem" unit alt_mod_num)
            )
        )
        (gen-st
            (cat "mod_mem" pre_mod_num)
        )
    )

    (defrole foreign_reg_mod_reg
        (vars
            (unit role_number venture foreign_unit foreign_venture name) (ias_nonce mod_num text)
        )
        (trace
            (recv
                (cat
                    unit
                    role_number
                    "i_am_starting"
                    ias_nonce
                    mod_num
                    (enc
                        "i_am_starting"
                        ias_nonce
                        (privk venture)
                    )
                )
            )
            (send
                (cat
                    unit
                    role_number
                    "i_am_starting"
                    ias_nonce
                    mod_num
                    (enc
                        "i_am_starting"
                        ias_nonce
                        (privk venture)
                    )
                )
            )
        )
    )

    (defrole foreign_mod
        (vars
            (foreign_unit role_number foreign_venture foreign_role_number name) (ias_nonce mod_num foreign_mod_num iah_nonce2 text)
        )
        (trace
            (recv
                (cat
                    unit
                    role_number
                    "i_am_starting"
                    ias_nonce
                    mod_num
                    (enc
                        "i_am_starting"
                        ias_nonce
                        (privk venture)
                    )
                )
            )
            (send
                (cat
                    foreign_unit
                    foreign_role_number
                    "i_am_here2"
                    iah_nonce2
                    foreign_mod_num
                    (enc
                        "i_am_here2"
                        iah_nonce2
                        (privk foreign_role_number)
                    )
                )
            )
        )
    )

    ;;; Module Registration Alternate Paths;;;

    ; Module Registration Rejection ;
    ; While rejection can be abandoned, this is just a shortened version of the option to repeat
    (defrole config_server_pre_rejection
        (vars
            (unit rr_role_number cont name) (rq_nonce2 cs_nonce4 text) (conf_mib locn)
        )
        (trace
            (recv
                (cat
                    unit
                    rr_role_number
                    "registrar_query2"
                    rq_nonce2
                    (enc
                        "registrar_query2"
                        rq_nonce2
                        (privk rr_role_number)
                    )
                )
            )
            (load conf_mib
                (cat "conf_mem" unit)
            )
            (send
                (cat
                    "0"
                    "cell_spec4"
                    cs_nonce4
                    (enc
                        "cell_spec4"
                        cs_nonce4
                        (privk cont)
                    )
                    unit
                )
            )
        )
        (gen-st
            (cat "conf_mem" unit)
        )
    )

    (defrole module_reject_repeat
        (vars
            (unit rr_role_number pre_role_number venture cont name) (rq_nonce2 cs_nonce4 mr_nonce1 mr_nonce2 rej_nonce yai_nonce1 iah_nonce1 mod_num1 pre_mod_num text) (module_mib1 locn)
        )
        (trace
            (send
                (cat
                    unit
                    rr_role_number
                    "registrar_query"
                    rq_nonce2
                    (enc
                        "registrar_query"
                        rq_nonce2
                        (privk rr_role_number)
                    )
                )
            )
            (recv
                (cat
                    "0"
                    "cell_spec4"
                    cs_nonce4
                    (enc
                        "cell_spec4"
                        cs_nonce4
                        (privk cont)
                    )
                    unit
                )
            )
            (stor module_mib
                (cat "mod_mem" unit)
            )
            (send
                (cat
                    unit
                    rr_role_number
                    "module_registration1"
                    mr_nonce1
                    (enc
                        "module_registration1"
                        mr_nonce1
                        (privk rr_role_number)
                    )
                )
            )
            (recv
                (cat
                    unit
                    "rejection"
                    rej_nonce
                    (enc
                        "rejection"
                        rej_nonce
                        (privk venture)
                    )
                )
            )
            (send
                (cat
                    unit
                    rr_role_number
                    "module_registration2"
                    mr_nonce2
                    (enc
                        "module_registration2"
                        mr_nonce2
                        (privk rr_role_number)
                    )
                )
            )
            (recv
                (cat
                    unit
                    "you_are_in1"
                    yai_nonce1
                    mod_num1
                    (enc
                        "you_are_in1"
                        yai_nonce1
                        (privk venture)
                    )
                )
            )
            (stor module_mib1
                (cat "mod_mem" mod_num1)
            )
            (recv
                (cat
                    unit
                    pre_role_number
                    "i_am_here1"
                    iah_nonce1
                    pre_mod_num
                    (enc
                        "i_am_here1"
                        iah_nonce1
                        (privk pre_role_number)
                    )
                )
            )
        )
    )

    (defrole registrar_reject_repeat
        (vars
            (unit rr_role_number venture name) (mr_nonce1 rej_nonce mr_nonce2 yai_nonce1 mod_num1 ias_nonce1 text) (reg_mib locn)
        )
        (trace
            (recv
                (cat
                    unit
                    rr_role_number
                    "module_registration1"
                    mr_nonce1
                    (enc
                        "module_registration1"
                        mr_nonce1
                        (privk rr_role_number)
                    )
                )
            )
            (send
                (cat
                    unit
                    "rejection"
                    rej_nonce
                    (enc
                        "rejection"
                        rej_nonce
                        (privk venture)
                    )
                )
            )
            (recv
                (cat
                    unit
                    rr_role_number
                    "module_registration2"
                    mr_nonce2
                    (enc
                        "module_registration2"
                        mr_nonce2
                        (privk rr_role_number)
                    )
                )
            )
            (send
                (cat
                    unit
                    "you_are_in1"
                    yai_nonce1
                    mod_num1
                    (enc
                        "you_are_in1"
                        yai_nonce1
                        (privk venture)
                    )
                )
            )
            (stor reg_mib
                (cat "reg_mem" mod_num1)
            )
            (send
                (cat
                    unit
                    rr_role_number
                    "i_am_starting1"
                    ias_nonce1
                    mod_num1
                    (enc
                        "i_am_starting1"
                        ias_nonce1
                        (privk venture)
                    )
                )
            )
        )
    )

    ; Registrar sends I_am_here with module_has_started, instead of I_am_starting"
    (defrole config_server_alt
        (vars
            (unit alt_role_number cont name) (req_nonce3 cs_nonce5 text) (conf_mib locn)
        )
        (trace
            (recv
                (cat
                    unit
                    alt_role_number
                    "registrar_query3"
                    rq_nonce3
                    (enc
                        "registrar_query3"
                        rq_nonce3
                        (privk alt_role_number)
                    )
                )
            )
            (load conf_mib
                (cat "conf_mem" unit)
            )
            (send
                (cat
                    "0"
                    "cell_spec5"
                    cs_nonce5
                    (enc
                        "cell_spec5"
                        cs_nonce5
                        (privk cont)
                    )
                    unit
                )
            )
        )
        (gen-st
            (cat "conf_mem" unit)
        )
    )

    (defrole mod_reg_alt
        (vars
            (unit alt_role_number cont venture name) (rq_nonce3 cs_nonce5 mr_nonce3 yai_nonce2 alt_mod_num iah_nonce3 text) (module_mib2 locn)
        )
        (trace
            (send
                (cat
                    unit
                    alt_role_number
                    "registrar_query3"
                    rq_nonce3
                    (enc
                        "registrar_query3"
                        rq_nonce3
                        (privk alt_role_number)
                    )
                )
            )
            (recv
                (cat
                    "0"
                    "cell_spec5"
                    cs_nonce5
                    (enc
                        "cell_spec5"
                        cs_nonce5
                        (privk cont)
                    )
                    unit
                )
            )
            (stor module_mib2
                (cat "mod_mem" unit)
            )
            (send
                (cat
                    unit
                    alt_role_number
                    "module_registration3"
                    mr_nonce3
                    (enc
                        "module_registration3"
                        mr_nonce3
                        (privk alt_role_number)
                    )
                )
            )
            (recv
                (cat
                    unit
                    "you_are_in2"
                    yai_nonce2
                    alt_mod_num
                    (enc
                        "you_are_in2"
                        yai_nonce2
                        (privk venture)
                    )
                )
            )
            (stor module_mib2
                (cat "mod_mem" alt_mod_num)
            )
            (recv
                (cat
                    unit
                    "i_am_here3"
                    iah_nonce3
                    pre_mod_num
                    (enc
                        "i_am_here3"
                        iah_nonce3
                        (privk venture)
                    )
                )
            )
        )
    )

    (defrole reg_mod_reg_alt
        (vars
            (unit alt_role_number venture name) (mr_nonce3 yai_nonce2 alt_mod_num pre_mod_num iah_nonce3 mhs_nonce text) (reg_mib locn)
        )
        (trace
            (recv
                (cat
                    unit
                    alt_role_number
                    "module_registration3"
                    mr_nonce3
                    (enc
                        "module_registration3"
                        mr_nonce3
                        (privk alt_role_number)
                    )
                )
            )
            (send
                (cat
                    unit
                    "you_are_in2"
                    yai_nonce2
                    alt_mod_num
                    (enc
                        "you_are_in2"
                        yai_nonce2
                        (privk venture)
                    )
                )
            )
            (load reg_mib
                (cat "reg_mem" pre_mod_num)
            )
            (send
                (cat
                    unit
                    "i_am_here3"
                    iah_nonce3
                    pre_mod_num
                    (enc
                        "i_am_here3"
                        iah_nonce3
                        (privk venture)
                    )
                )
            )
            (stor reg_mib
                (cat "reg_mem" alt_mod_num)
            )
            (send
                (cat
                    unit
                    "module_has_started"
                    mhs_nonce
                    alt_mod_num
                    (enc
                        "module_has_started"
                        mhs_nonce
                        (privk venture)
                    )
                )
            )
        )
        (gen-st
            (cat "reg_mem" pre_mod_num)
        )
    )

    (defrole foreign_reg_mod_reg_alt
        (vars
            (unit venture name) (mhs_nonce alt_mod_num text)
        )
        (trace
            (recv
                (cat
                    unit
                    "module_has_started"
                    mhs_nonce
                    alt_mod_num
                    (enc
                        "module_has_started"
                        mhs_nonce
                        (privk venture)
                    )
                )
            )
            (send
                (cat
                    unit
                    "module_has_started"
                    mhs_nonce
                    alt_mod_num
                    (enc
                        "module_has_started"
                        mhs_nonce
                        (privk venture)
                    )
                )
            )
        )
    )

    (defrole foreign_mod_alt
        (vars
            (unit venture name) (mhs_nonce alt_mod_num text)
        )
        (trace
            (recv
                (cat
                    unit
                    "module_has_started"
                    mhs_nonce
                    alt_mod_num
                    (enc
                        "module_has_started"
                        mhs_nonce
                        (privk venture)
                    )
                )
            )
        )
    )

    ;;; Reconnection ;;;
    (defrole config_server_reconn
        (vars
            (unit reconn_role_number cont name) (rq_nonce4 cs_nonce6 text) (conf_mib locn)
        )
        (trace
            (recv
                (cat
                    unit
                    reconn_role_number
                    "registrar_query4"
                    rq_nonce4
                    (enc
                        "registrar_query4"
                        rq_nonce4
                        (privk reconn_role_number)
                    )
                )
            )
            (load conf_mib
                (cat "conf_mem" unit)
            )
            (send
                (cat
                    "0"
                    "cell_spec6"
                    cs_nonce6
                    (enc
                        "cell_spec6"
                        cs_nonce6
                        (privk cont)
                    )
                    unit
                )
            )
        )
        (gen-st
            (cat "conf_mem" unit)
        )
    )
    
    (defrole module_reconn
        (vars
            (unit reconn_role_number cont name) (ryad_nonce rc_nonce rq_nonce4 cs_nonce6 text) (mod_mib locn)
        )
        (trace
            (send
                (cat
                    unit
                    reconn_role_number
                    "registrar_query4"
                    rq_nonce4
                    (enc
                        "registrar_query4"
                        rq_nonce4
                        (privk reconn_role_number)
                    )
                )
            )
            (recv
                (cat
                    "0"
                    "cell_spec6"
                    cs_nonce6
                    (enc
                        "cell_spec6"
                        cs_nonce6
                        (privk cont)
                    )
                    unit
                )
            )
            (load module_mib
                (cat "mod_mem" unit pre_role_number pre_mod_num)
            )
            (send
                (cat
                    unit
                    reconn_role_number
                    "reconnect"
                    rc_nonce
                    (enc
                        "reconnect"
                        rc_nonce
                        (privk reconn_role_number)
                    )
                    pre_role_number
                    pre_mod_num
                )
            )
            (recv
                (cat
                    unit
                    "reconnected/you_are_dead"
                    ryad_nonce
                    (enc
                        "reconnected/you_are_dead"
                        ryad_nonce
                        (privk venture)
                    )
                )
            )
            ; At which point, unregistration is followed if you_are_dead is sent
        )
        (gen-st
            (cat "mod_mem" unit pre_role_number pre_mod_num)
        )
    )

    (defrole registrar_reconnect
        (vars
            (unit reconn_role_number pre_role_number name) (rc_nonce pre_mod_num ryad_nonce text)
        )
        (trace
            (send
                (cat
                    unit
                    reconn_role_number
                    "reconnect"
                    rc_nonce
                    (enc
                        "reconnect"
                        rc_nonce
                        (privk reconn_role_number)
                    )
                    pre_role_number
                    pre_mod_num
                )
            )
            (send
                (cat
                    unit
                    "reconnected/you_are_dead"
                    ryad_nonce
                    (enc
                        "reconnected/you_are_dead"
                        ryad_nonce
                        (privk venture)
                    )
                )
            )
        )
    )

    ;;; Resynchronization ;;;
    (defrole registrar_resync
        (vars
            (mod_num1 mod_num2 cstat_nonce text) (foreign_unit unit venture name)
        )
        (trace
            (load reg_mib
                (cat "reg_mem" mod_num1)
            )
            (load reg_mib
                (cat "reg_mem" mod_num2)
            )
            (load
                (cat "reg_mem" foreign_unit)
            )
            (send
                (cat
                    unit
                    "cell_status"
                    cstat_nonce
                    (enc
                        "cell_status"
                        cstat_nonce
                        (privk venture)
                    )
                )
            )
        )
        (gen-st (cat "reg_mem" mod_num1))
        (gen-st (cat "reg_mem" mod_num2))
        (gen-st (cat "reg_mem" foreign_unit))
    )

    (defrole mod1_resync
        (vars
            (unit venture name) (cstat_nonce text)
        )
        (trace
            (recv
                (cat
                    unit
                    "cell_status"
                    cstat_nonce
                    (enc
                        "cell_status"
                        cstat_nonce
                        (privk venture)
                    )
                )
            )
        )
    )

    (defrole mod2_resync
        (vars
            (unit venture name) (cstat_nonce text)
        )
        (trace
            (recv
                (cat
                    unit
                    "cell_status"
                    cstat_nonce
                    (enc
                        "cell_status"
                        cstat_nonce
                        (privk venture)
                    )
                )
            )
        )
    )

    (defrole foreign_reg_resync
        (vars
            (unit venture name) (cstat_nonce text)
        )
        (trace
            (recv
                (cat
                    unit
                    "cell_status"
                    cstat_nonce
                    (enc
                        "cell_status"
                        cstat_nonce
                        (privk venture)
                    )
                )
            )
            (send
                (cat
                    unit
                    "cell_status"
                    cstat_nonce
                    (enc
                        "cell_status"
                        cstat_nonce
                        (privk venture)
                    )
                )
            )
        )
    )

    (defrole foreign_mod_resync
        (vars
            (unit venture name) (cstat_nonce text)
        )
        (trace
            (recv
                (cat
                    unit
                    "cell_status"
                    cstat_nonce
                    (enc
                        "cell_status"
                        cstat_nonce
                        (privk venture)
                    )
                )
            )
        )
    )

    ;;; Subscription/Invitation Assertion/Cancellation/Unregistration ;;;
    (defrole mod_subscribe
        (vars
            (module_mib locn) (unit role_number name) (s_nonce text)
        )
        (trace
            (load module_mib
                (cat "mod_mem" unit)
            )
            (send
                (cat
                    unit
                    role_number
                    "ungregister/subscribe/unsubscribe/invite/disinvite"
                    s_nonce
                    (enc
                        "ungregister/subscribe/unsubscribe/invite/disinvite"
                        s_nonce
                        (privk role_number)
                    )
                )
            )
        )
        (gen-st (cat "mod_mem" unit))
    )

    (defrole reg_mod_sub
        (vars
            (unit role_number name) (s_nonce text)
        )
        (trace
            (recv
                (cat
                    unit
                    role_number
                    "ungregister/subscribe/unsubscribe/invite/disinvite"
                    s_nonce
                    (enc
                        "ungregister/subscribe/unsubscribe/invite/disinvite"
                        s_nonce
                        (privk role_number)
                    )
                )
            )
            (send
                (cat
                    unit
                    role_number
                    "ungregister/subscribe/unsubscribe/invite/disinvite"
                    s_nonce
                    (enc
                        "ungregister/subscribe/unsubscribe/invite/disinvite"
                        s_nonce
                        (privk role_number)
                    )
                )
            )
        )
    )

    (defrole pre_mod_sub
        (vars
            (unit role_number name) (s_nonce text)
        )
        (trace
            (recv
                (cat
                    unit
                    role_number
                    "ungregister/subscribe/unsubscribe/invite/disinvite"
                    s_nonce
                    (enc
                        "ungregister/subscribe/unsubscribe/invite/disinvite"
                        s_nonce
                        (privk role_number)
                    )
                )
            )
        )
    )

    (defrole foreign_reg_mod_sub
        (vars
            (unit role_number name) (s_nonce text)
        )
        (trace
            (recv
                (cat
                    unit
                    role_number
                    "ungregister/subscribe/unsubscribe/invite/disinvite"
                    s_nonce
                    (enc
                        "ungregister/subscribe/unsubscribe/invite/disinvite"
                        s_nonce
                        (privk role_number)
                    )
                )
            )
            (send
                (cat
                    unit
                    role_number
                    "ungregister/subscribe/unsubscribe/invite/disinvite"
                    s_nonce
                    (enc
                        "ungregister/subscribe/unsubscribe/invite/disinvite"
                        s_nonce
                        (privk role_number)
                    )
                )
            )
        )
    )

    (defrole foreign_mod_sub
        (vars
            (unit role_number name) (s_nonce text)
        )
        (trace
            (recv
                (cat
                    unit
                    role_number
                    "ungregister/subscribe/unsubscribe/invite/disinvite"
                    s_nonce
                    (enc
                        "ungregister/subscribe/unsubscribe/invite/disinvite"
                        s_nonce
                        (privk role_number)
                    )
                )
            )
        )
    )
)
