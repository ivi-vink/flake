(local heirline (require :heirline))
(local conditions (require :heirline.conditions))
(local utils (require :heirline.utils))
(local colors (let [kanagawa-colors (require :kanagawa.colors)]
                (kanagawa-colors.setup)))

(local Align {:provider "%="})
(local Space {:provider " "})
(fn with [tbl with-kv]
  (local w {})
  (each [k v (pairs tbl)]
    (tset w k v))
  (each [k v (pairs with-kv)]
    (tset w k v))
  w)

(heirline.load_colors colors)
(fn palette [name]
  (. colors :palette name))

(fn theme [theme name]
  (. colors :theme theme name))

(var FileNameBlock
     {;; let's first set up some attributes needed by this component and it's children
      :init (lambda [self]
              (tset self :filename (vim.api.nvim_buf_get_name 0)))})

(local FileName
       {:provider (lambda [self]
                    ;; first, trim the pattern relative to the current directory. For other
                    ;;- options, see :h filename-modifers
                    (var filename (vim.fn.fnamemodify (. self :filename) ":."))
                    (if (= filename "")
                        (set filename "[No Name]")
                        ;;- now, if the filename would occupy more than 1/4th of the available
                        ;;-- space, we trim the file path to its initials
                        ;;-- See Flexible Components section below for dynamic truncation
                        (if (not (conditions.width_percent_below (length filename)
                                                                 0.25))
                            (set filename (vim.fn.pathshorten filename))))
                    filename)
        :hl {:fg (. (utils.get_highlight :Directory) :fg)}})

(local FileNameModifier {:hl (lambda []
                               (when vim.bo.modified
                                 {:fg (theme :diag :warning)
                                  :bold true
                                  :force true}))})

(local FileFlags [{:condition (lambda [] vim.bo.modified)
                   :provider "[+]"
                   :hl {:fg (theme :diag :warning)}}])

(set FileNameBlock (utils.insert FileNameBlock
                                 (utils.insert FileNameModifier FileName)
                                 FileFlags {:provider "%<"}))

(local DAPMessages {:condition (lambda []
                                 (local dap (require :dap))
                                 (local session (dap.session))
                                 (not (= session nil)))
                    :provider (lambda []
                                (local dap (require :dap))
                                (.. " " (dap.status)))
                    :hl :Debug})

(local Ruler {;; %l = current line number
              ;; %L = number of lines in the buffer
              ;; %c = column number
              ;; %P = percentage through file of displayed window
              :provider "%7(%l/%3L%):%2c %P"})

(local ScrollBar
       {:static {:sbar ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"]}
        ;; Another variant, because the more choice the better.
        ;; sbar { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻'}}
        :provider (lambda [self]
                    (local curr_line (. (vim.api.nvim_win_get_cursor 0) 1))
                    (local lines (vim.api.nvim_buf_line_count 0))
                    (local i
                           (- (length self.sbar)
                              (math.floor (* (/ (- curr_line 1) lines)
                                             (length (. self :sbar))))))
                    (string.rep (. self :sbar i) 2))
        :hl {:fg (theme :syn :fun) :bg (theme :ui :bg)}})

(local Nix
       {:condition (fn [] vim.env.IN_NIX_SHELL)
        :provider (fn [self]
                    (local purity vim.env.IN_NIX_SHELL)
                    (local name vim.env.name)
                    (.. "" purity "(" name ")"))
        :hl {:fg (theme :syn :fun) :bold true :bg (theme :ui :bg_m3)}})

(local RecordingMacro {:condition #(not= "" (vim.fn.reg_recording))
                       :provider (fn [self]
                                   (.. "Recording... " (vim.fn.reg_recording)))
                       :hl {:fg (theme :syn :fun)
                            :bold true
                            :bg (theme :ui :bg_m3)}})

(local harpoon (require :harpoon))
(local harpoon-mark (require :harpoon.mark))
(local harpoon-colors [(theme :syn :identifier)
                       (theme :syn :identifier)
                       (theme :syn :identifier)])

(fn mark-component [i mark]
  (utils.insert {} {:hl {:bg (if (= mark.filename
                                    (vim.fn.fnamemodify (vim.api.nvim_buf_get_name 0)
                                                        ":."))
                                 (theme :ui :bg_p1)
                                 (theme :ui :bg_m1))
                         :bold true
                         :fg (. harpoon-colors i)}
                    :provider (fn [self]
                                (.. " M" i " "))}))

;{:hl {:fg (theme :syn :fun)} :provider (vim.fn.pathshorten mark.filename)}))
; {:hl {:bold true :fg (. harpoon-colors i)} :provider ")"} Space))

(local HarpoonMarks
       (utils.insert {:hl :TabLineSel
                      :condition #(< 0
                                     (length (. (harpoon.get_mark_config)
                                                :marks)))}
                     {:init (lambda [self]
                              (local mark-list
                                     (. (harpoon.get_mark_config) :marks))
                              (each [i mark (ipairs mark-list)]
                                (tset self i
                                      (self:new (mark-component i mark) i)))
                              (while (> (length self) (length mark-list))
                                (table.remove self (length self))))}))

(local Tabpage
       {:provider (lambda [self]
                    (fn fnamemod [name mod]
                      (vim.fn.fnamemodify name mod))

                    (fn format-name [name]
                      (if (= name "") "[No Name]"
                          (fnamemod name ":t")))

                    (.. "%" self.tabnr "T " self.tabnr " "))
        :hl (lambda [self]
              (if (not self.is_active) :TabLine :TabLineSel))})

(fn active-tab-hrpn [self]
  (local hl {})
  (if (. self :is_active)
      (do
        (tset hl :fg (theme :syn :identifier))
        (tset hl :bold true)))
  hl)

(fn active-hl [hl]
  (lambda [self]
    (if self.is_active
        hl
        {})))

(fn tab-visible-buffers [tab]
  (local visible (vim.fn.tabpagebuflist tab))
  (if (= visible 0)
      []
      visible))

(fn tab-harpoon-marks [tab]
  (local visible (tab-visible-buffers tab))
  (local tab-buffers (accumulate [buffers [] _ buf (ipairs visible)]
                       (do
                         (if (not (vim.tbl_contains buffers buf))
                             (table.insert buffers buf))
                         buffers)))
  (icollect [_ buf (ipairs tab-buffers)]
    (do
      (local status (harpoon-mark.status buf))
      (if (not= status "")
          status))))

(local Tabpage
       (utils.insert Tabpage {:hl active-tab-hrpn :provider "🌊 [ "}
                     {:hl (active-hl {:fg (theme :syn :fun)})
                      :provider (lambda [self]
                                  (local harpoon_marks
                                         (tab-harpoon-marks self.tabnr))
                                  (table.concat harpoon_marks " "))}
                     {:hl active-tab-hrpn :provider " ] %T"}))

(local TabpageClose {:provider "%999X  %X" :hl :TabLine})

(local TabPages
       {;; only show this component if there's 2 or more tabpages
        :condition (lambda []
                     (>= (length (vim.api.nvim_list_tabpages)) 1))})

(local TabPages (utils.insert TabPages (utils.make_tablist Tabpage)
                              TabpageClose))

(local dispatch-get-request (. vim.fn "dispatch#request"))
(local Dispatch (utils.insert {:init (fn [self]
                                       (set self.req (dispatch-get-request)))
                               :condition (fn []
                                            (not (vim.tbl_isempty (dispatch-get-request))))}
                              {:provider "dispatch("
                               :hl (fn [self]
                                     {:fg (if (= 1 self.req.completed)
                                              (theme :syn :fun)
                                              (theme :diag :warning))
                                      :bold true})}
                              {:provider (fn [self]
                                           self.req.command)
                               :hl {:fg (theme :syn :string) :bold false}}
                              {:provider ")"
                               :hl (fn [self]
                                     {:fg (if (= 1 self.req.completed)
                                              (theme :syn :fun)
                                              (theme :diag :warning))
                                      :bold true})}))

(local StatusLine [FileNameBlock
                   Space
                   HarpoonMarks
                   Space
                   TabPages
                   DAPMessages
                   Space
                   RecordingMacro
                   Dispatch
                   Align
                   Space
                   Nix
                   Space
                   Ruler
                   Space
                   ScrollBar
                   Space])

(heirline.setup {:statusline StatusLine})
