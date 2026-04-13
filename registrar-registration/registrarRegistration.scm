(herald "Meta-AMS (MAMS) Registrar Registration")

(defprotocol mams_registrar_reg basic
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
            (stor
                reg_mib
                (cat "cell_spec1" foreign_unit)
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
            (stor
                conf_mib
                (cat "announce_registrar" unit)
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
                    (cat "foreign_heartbeat" foreign_unit)
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
                (cat "foreign_cell_spec" foreign_unit)
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
                (cat "foreign_cell_spec" foreign_unit)
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
            (load
                conf_mib
                (cat "announce_registrar" unit)
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
            (cat "announce_registrar" unit)
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
            (ar_nonce_r text) (reg_endpoint_name venture unit name) (ar_ref text)
            (rr_nonce text) (cont name)
        )
        (trace
            (send 
                (cat
                    ; header
                    (mpdu_header
                        venture
                        unit
                        "0"
                        ar_ref
                    )
                    ; digital signature
                    (cat
                        ar_nonce_r
                        (enc
                            ar_nonce_r
                            "known_string"
                            (privk venture)
                        )
                    )
                    ; supplementary data
                    reg_endpoint_name
                )
            )
            (recv 
                (cat
                    ; header
                    (mpdu_header
                        "0"
                        "0"
                        "0"
                        ar_ref
                    )
                    ; digital signature
                    (cat
                        rr_nonce
                        (enc
                            rr_nonce
                            "known_string"
                            (privk cont)
                        )
                    )
                    ; supplementary data
                    "refusal reason"
                )
            )
        )
    )

    (defrole config_server_reject
        (vars
            (ar_nonce_r text) (reg_endpoint_name venture unit name) (ar_ref text)
            (rr_nonce text) (cont name)
        )
        (trace
            (recv 
                (cat
                    ; header
                    (mpdu_header
                        venture
                        unit
                        "0"
                        ar_ref
                    )
                    ; digital signature
                    (cat
                        ar_nonce_r
                        (enc
                            ar_nonce_r
                            "known_string"
                            (privk venture)
                        )
                    )
                    ; supplementary data
                    reg_endpoint_name
                )
            )
            (send 
                (cat
                    ; header
                    (mpdu_header
                        "0"
                        "0"
                        "0"
                        ar_ref
                    )
                    ; digital signature
                    (cat
                        rr_nonce
                        (enc
                            rr_nonce
                            "known_string"
                            (privk cont)
                        )
                    )
                    ; supplementary data
                    "refusal reason"
                )
            )
        )
    )
)

(defskeleton mams_registrar_reg
    (vars
        (ar_nonce text) (venture cont name)
    )
    (defstrandmax new_registrar
        (ar_nonce ar_nonce) (venture venture) (cont cont)
    )
    (uniq-orig ar_nonce)
    (non-orig (privk venture))
    (non-orig (privk cont))
)
(defskeleton mams_registrar_reg
    (vars
        (rn_nonce cs_nonce1 text) (venture cont name)
    )
    (defstrandmax config_server_accept
        (rn_nonce rn_nonce) (cs_nonce1 cs_nonce1) (venture venture) (cont cont)
    )
    (uniq-orig rn_nonce)
    (uniq-orig cs_nonce1)
    (non-orig (privk venture))
    (non-orig (privk cont))
)
(defskeleton mams_registrar_reg
    (vars
        (hb_nonce2 cs_nonce2 text) (foreign_venture cont name)
    )
    (defstrandmax config_server_forward
        (hb_nonce2 hb_nonce2) (cs_nonce2 cs_nonce2) (foreign_venture foreign_venture) (cont cont)
    )
    (uniq-orig hb_nonce2)
    (uniq-orig cs_nonce2)
    (non-orig (privk foreign_venture))
    (non-orig (privk cont))
)
(defskeleton mams_registrar_reg
    (vars
        (hb_nonce1 text) (foreign_venture cont name)
    )
    (defstrandmax foreign_registrars
        (hb_nonce1 hb_nonce1) (foreign_venture foreign_venture) (cont cont)
    )
    (uniq-orig hb_nonce1)
    (non-orig (privk foreign_venture))
    (non-orig (privk cont))
)
(defskeleton mams_registrar_reg
    (vars
        (ar_nonce_r text) (venture cont name)
    )
    (defstrand registrar_rejected 2 
        (ar_nonce_r ar_nonce_r) (venture venture) (cont cont)
    )
    (uniq-orig ar_nonce_r)
    (non-orig (privk venture))
    (non-orig (privk cont))
)
(defskeleton mams_registrar_reg
    (vars
        (rr_nonce text) (venture cont name)
    )
    (defstrand config_server_reject 2
        (rr_nonce rr_nonce) (venture venture) (cont cont)
    )
    (uniq-orig rr_nonce)
    (non-orig (privk venture))
    (non-orig (privk cont))
)