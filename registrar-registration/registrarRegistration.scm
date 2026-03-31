(herald "Meta-AMS (MAMS) Registrar Registration")
; multiple roles per party
; each store and load in a different run???

; continuum1:{ venture1:{ unit1:{ cell1, cell2 }}}
; continuum2:{ venture1:{ unit1:{ cell1, cell2 }}, 
               venture2:{ unit1.2:{ cell1.2.1, cell1.2.2 }}}
; continuum3:{ venture2:{ unit1.2:{ cell1.2.1, cell1.2.2 }}}

; unit is an element of a venture, cell is unit intersection continuum

; mpdu structure
    ; header
        ; version number
        ; checksum flag                                             (presence)
        ; mpdu type                                                 (message type, no need to append message—see supp data below)
            ; _TYPE (indicated by num)_|_____REFERENCE_____|__SUPP DATA__
            ; heartbeat                 (heartbeat source)
            ; rejection                 (echo)              (refusal reason)
            ; you_are_dead              (0)
            ; registrar_noted           (echo)
            ; registrar_unknown         (echo)
            ; reconnected               (echo)
            ; announce_registrar        (0)                 (MAMS endpoint name)
            ; invite                    (module id)         (invitation assertion structure)
            ; disinvite                 (module id)         (invitation cancellation structure)
            ; cell_spec                 (echo)              (cell descriptor)
            ; registrar_query           (query number)      (MAMS endpoint name)
            ; module_registration       (query number)      (contact summary)
            ; you_are_in                (echo)              (assigned module number)
            ; I_am_starting             (module id)         (contact summary)
            ; I_am_here                 (0)                 (module status list)
            ; subscribe                 (module id)         (subscription assertion structure)
            ; unsubscribe               (module id)         (subscription cancellation structure)
            ; I_am_stopping             (module id)         
            ; reconnect                 (query number)      (reconnect structure)
            ; cell_status               (module id)         (module list)
            ; module_has_started        (module id)         (contact summary)
            ; I_am_running              (0)
            ; module_status             (module id)         (module status list)
        ; sender's venture number                                   (original sender; 0 if conf)
        ; sender's unit number                                      (original sender; 0 if conf)
        ; sender's role number                                      (original sender; 0 if reg or conf)
        ; length of digital signature
        ; length of supp data
        ; reference                                                 (ONE of the following, vary by mpdu type)
            ; query number                                          (sequence, each entity has own series of query numbers)
            ; echo                                                  (reference number of causally preceding mpdu)
            ; heartbeat source                                      (module's number or 0)
            ; module id                                             (above module's number + unit number * 256 + role number * 16777216)
        ; time tag
    ; digital signature
            ; 1) 4 char nonce
            ; 2) encrypt nonce + public string                      (enc n string (privk))
                ; module    —role private key
                ; registrar —application private key
                ; conf      —continuum private key
        ; nonce + encrypted string
    ; supplementary data
        ; endpoint name                                             (endpoint's name)
        ; cell descriptor                                           (registrar's unit number+cell's registrar endpoint name)
        ; module list                                               (length + list of 8-bit module numbers)
        ; assigned module number                                    (module number assigned to module) by registrar? conf?
        ; delivery point name                                       (transport service name and delivery endpoint)
        ; delivery vector                                           (delivery vector id number + number of delivery points + list of delivery point names)
        ; delivery vector list                                      (length + list of above delivery vectors)
        ; contact summary                                           (endpoint name + delivery vector list)
        ; subscription assertion structure                          (subject number + cont number with all subscribed modules + unit number with all subscribed modules + role number for subscribed modules + delivery vector number + priority + flow identifier)
        ; invitation assertion structure                            (...)
        ; subscription list                                         (number of subscription assertions + list of assertion structures (identifies subjects subscribing to))
        ; invitation list                                           (number of invitation assertions + list of assertion structures (not subscribe, but willing to receive))
        ; declaration structure                                     (subscription list + invitation list)
        ; module status structure                                   (unit number + module number + originally registered-role number + contact summary + declaration structure)
        ; module status list                                        (number of module status structures + list of structures)
        ; subscription cancellation structure                       (subject number + cont number with all subscribed modules + unit number ... + role number ...)
        ; invitation cancellation structure                         (...)
        ; reconnect structure                                       (own module status structure + module list)
        ; refusal reason                                            (numerical code)
    ; checksum

(defmacro (announce_registrar_mpdu)
    (cat
        ; header
        (mpdu_header
            venture
            unit
            reg_conf_role
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
            config
            config
            reg_conf_role
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

(defmacro (cell_spec_mpdu echo unit endpoint nonce)
    (cat
        ; header
        (mpdu_header
            config
            config
            reg_conf_role
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
        (cat
            unit
            endpoint
        )
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
            (ar_nonce text) (reg_endpoint_name venture unit reg_conf_role name) (ar_ref text)
            (rn_nonce text) (config cont name)
            (foreign_endpoint_name foreign_unit name) (cs_nonce1 text)
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
            (store 
                reg_mib
                (cell_spec_payload foreign_unit foreign_endpoint_name)
            )
        )
    )

    (defrole config_server_accept
        (vars
            (ar_nonce text) (reg_endpoint_name venture unit reg_conf_role name) (ar_ref text)
            (conf_mib locn)
            (rn_nonce text) (config cont name)
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
                foreign_endpoint_name
                foreign_unit 
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
            (hb_nonce1 text) (foreign_venture foreign_unit reg_conf_role name)
            (hb_nonce2 text) (config cont name)
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
                    reg_conf_role
                    reg_conf_role
                    hb_nonce1
                    foreign_venture
                )
            )
            (send
                (heartbeat_mpdu
                    config
                    config
                    reg_conf_role
                    reg_conf_role ; the reference number for a non-module entity is 0, the same as the role number
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
            (hb_nonce1 text) (foreign_venture foreign_unit reg_conf_role name)
            (hb_nonce2 text) (config cont name)
            (cs_nonce2 ar_ref text)
            (foreign_mib locn) (reg_endpoint_name unit name)
        )
        (trace
            (send
                (heartbeat_mpdu
                    foreign_venture
                    foreign_unit
                    reg_conf_role
                    reg_conf_role
                    hb_nonce1
                    foreign_venture
                )
            )
            (recv
                (heartbeat_mpdu
                    config
                    config
                    reg_conf_role
                    reg_conf_role
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