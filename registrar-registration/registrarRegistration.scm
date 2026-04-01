(herald "Meta-AMS (MAMS) Registrar Registration")

(defmacro (announce_registrar_mpdu)
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
            ar_nonce
            (enc
                ar_nonce
                "known_string"
                (privk venture)
            )
        )
        ; supplementary data
        reg_endpoint_name
    )
)

(defmacro (registrar_noted_mpdu)
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
            rn_nonce
            (enc
                rn_nonce
                "known_string"
                (privk cont)
            )
        )
        ; supplementary data
    )
)

(defmacro (cell_spec_mpdu echo payload_tuple nonce)
    (cat
        ; header
        (mpdu_header
            "0"
            "0"
            "0"
            echo
        )
        ; digital signature
        (cat
            nonce
            (enc
                nonce
                "known_string"
                (privk cont)
            )
        )
        ; supplementary data
        payload_tuple
    )
)

(defmacro (heartbeat_mpdu venture unit role ref_heartbeat_source n key_name)
    (cat
        ; header
        (mpdu_header
            venture
            unit
            role
            ref_heartbeat_source
        )
        ; digital signature
        (cat
            n
            (enc
                n
                "known_string"
                (privk key_name)
            )
        )
        ; supplementary data
    )
)

(defprotocol mams_registrar_reg basic
    (defrole new_registrar
        (vars
            (ar_nonce text) (reg_endpoint_name venture unit name) (ar_ref text)
            (rn_nonce text) (cont name)
            (foreign_endpoint_name foreign_unit name) (cs_nonce1 text) (reg_mib locn)
        )
        (trace
            (send 
                (announce_registrar_mpdu)
            )
            (recv 
                (registrar_noted_mpdu)
            )
            (recv 
                (cell_spec_mpdu 
                    ar_ref 
                    (cell_spec_payload foreign_unit foreign_endpoint_name)
                    cs_nonce1
                )
            )
            (stor
                reg_mib
                (cell_spec_payload foreign_unit foreign_endpoint_name)
            )
        )
    )

    (defrole config_server_accept
        (vars
            (ar_nonce text) (reg_endpoint_name venture unit name) (ar_ref text)
            (conf_mib locn)
            (rn_nonce text) (cont name)
            (foreign_endpoint_name foreign_unit name)
            (cs_nonce1 text)
        )
        (trace
            (recv 
                (announce_registrar_mpdu)
            )
            (stor 
                conf_mib
                (cell_spec_payload unit reg_endpoint_name)
            )
            (send 
                (registrar_noted_mpdu)
            )
            (load conf_mib 
                (cell_spec_payload foreign_unit foreign_endpoint_name)
            )
            (send 
                (cell_spec_mpdu 
                    ar_ref 
                    (cell_spec_payload foreign_unit foreign_endpoint_name)
                    cs_nonce1
                )
            )
        )
        (gen-st (cell_spec_payload foreign_unit foreign_endpoint_name))
    )

    (defrole config_server_forward
        (vars
            (conf_mib locn) (foreign_unit foreign_endpoint_name name)
            (hb_nonce1 text) (foreign_venture name)
            (hb_nonce2 text) (cont name)
            (unit reg_endpoint_name name)
            (cs_nonce2 ar_ref text)
        )
        (trace
            (stor ; this information is either preloaded, sent, etc., up to implementation
                conf_mib
                (cell_spec_payload foreign_unit foreign_endpoint_name)
            )
            (recv
                (heartbeat_mpdu
                    foreign_venture
                    foreign_unit
                    "0"
                    "0"
                    hb_nonce1
                    foreign_venture
                )
            )
            (send
                (heartbeat_mpdu
                    "0"
                    "0"
                    "0"
                    "0" ; the reference number for a non-module entity is 0, the same as the role number
                    hb_nonce2
                    cont
                )
            )
            (load conf_mib
                (cell_spec_payload unit reg_endpoint_name)
            )
            (send
                (cell_spec_mpdu
                    ar_ref
                    (cell_spec_payload unit reg_endpoint_name)
                    cs_nonce2
                )
            )
        )
        (gen-st (cell_spec_payload unit reg_endpoint_name))
    )

    (defrole foreign_registrars
        (vars
            (hb_nonce1 text) (foreign_venture foreign_unit name)
            (hb_nonce2 text) (cont name)
            (cs_nonce2 ar_ref text)
            (foreign_mib locn) (reg_endpoint_name unit name)
        )
        (trace
            (send
                (heartbeat_mpdu
                    foreign_venture
                    foreign_unit
                    "0"
                    "0"
                    hb_nonce1
                    foreign_venture
                )
            )
            (recv
                (heartbeat_mpdu
                    "0"
                    "0"
                    "0"
                    "0"
                    hb_nonce2
                    cont
                )
            )
            (recv
                (cell_spec_mpdu
                    ar_ref
                    (cell_spec_payload unit reg_endpoint_name)
                    cs_nonce2
                )
            )
            (stor foreign_mib
                (cell_spec_payload unit reg_endpoint_name)
            )
        )
    )

    (lang
        (mpdu_header (tuple 4))
        ; venture number (name)
        ; unit number (name)
        ; role number (name)
        ; reference number (per strand)
        (cell_spec_payload (tuple 2))
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