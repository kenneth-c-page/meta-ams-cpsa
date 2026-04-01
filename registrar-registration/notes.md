; multiple roles per party
; each store and load in a different run???

; continuum1:{ venture1:{ unit1:{ cell1, cell2 }}}
; continuum2:{ venture1:{ unit1:{ cell1, cell2 }}, 
;              venture2:{ unit1.2:{ cell1.2.1, cell1.2.2 }}}
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
