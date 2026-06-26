{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 8,
      "minor": 6,
      "revision": 0,
      "architecture": "x64",
      "modernui": 1
    },
    "classnamespace": "box",
    "rect": [
      100,
      100,
      520,
      460
    ],
    "boxes": [
      {
        "box": {
          "id": "plugin",
          "maxclass": "newobj",
          "text": "plugin~",
          "numinlets": 1,
          "numoutlets": 3,
          "outlettype": [
            "signal",
            "signal",
            ""
          ],
          "patching_rect": [
            40,
            180,
            60,
            22
          ]
        }
      },
      {
        "box": {
          "id": "sum",
          "maxclass": "newobj",
          "text": "+~",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            "signal"
          ],
          "patching_rect": [
            40,
            230,
            40,
            22
          ]
        }
      },
      {
        "box": {
          "id": "gen",
          "maxclass": "newobj",
          "text": "gen~",
          "numinlets": 1,
          "numoutlets": 2,
          "outlettype": [
            "signal",
            "signal"
          ],
          "patching_rect": [
            40,
            290,
            200,
            22
          ],
          "patcher": {
            "fileversion": 1,
            "appversion": {
              "major": 8,
              "minor": 6,
              "revision": 0,
              "architecture": "x64",
              "modernui": 1
            },
            "classnamespace": "dsp.gen",
            "rect": [
              0,
              0,
              640,
              600
            ],
            "boxes": [
              {
                "box": {
                  "id": "in1",
                  "maxclass": "newobj",
                  "text": "in 1",
                  "numinlets": 0,
                  "numoutlets": 1,
                  "outlettype": [
                    ""
                  ],
                  "patching_rect": [
                    40,
                    30,
                    32,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "cb",
                  "maxclass": "codebox",
                  "code": "Param az(0);\nParam el(0);\nParam dist(2);\nParam headcm(8.75);\nHistory xL(0), yL(0);\nHistory xR(0), yR(0);\ncc = 343;\na = headcm * 0.01;\nazr = az * 0.01745329;\nelr = el * 0.01745329;\nath = abs(azr);\nthE = (ath <= 1.5707963) ? ath : (3.1415927 - ath);\nitd = (a / cc) * (thE + sin(thE)) * cos(elr);\ndsmp = itd * samplerate;\nrl = (azr > 0);\ndlL = rl ? dsmp : 0;\ndlR = rl ? 0 : dsmp;\nsL = delay(in1, dlL, 512);\nsR = delay(in1, dlR, 512);\ncosI = sin(azr) * cos(elr);\nalL = clamp(1 - cosI, 0.1, 1.9);\nalR = clamp(1 + cosI, 0.1, 1.9);\ng = cc / a;\nK = 2 * samplerate;\nden = g + K;\nb0L = (g + alL*K)/den; b1L = (g - alL*K)/den; a1L = (g - K)/den;\nb0R = (g + alR*K)/den; b1R = (g - alR*K)/den; a1R = (g - K)/den;\noL = b0L*sL + b1L*xL - a1L*yL;\nxL = sL; yL = oL;\noR = b0R*sR + b1R*xR - a1R*yR;\nxR = sR; yR = oR;\ndg = min(1, 1.5 / max(0.4, dist));\nout1 = oL * dg;\nout2 = oR * dg;\n",
                  "numinlets": 1,
                  "numoutlets": 2,
                  "outlettype": [
                    "",
                    ""
                  ],
                  "patching_rect": [
                    40,
                    80,
                    360,
                    420
                  ],
                  "fontname": "Menlo",
                  "fontsize": 11.0
                }
              },
              {
                "box": {
                  "id": "o1",
                  "maxclass": "newobj",
                  "text": "out 1",
                  "numinlets": 1,
                  "numoutlets": 0,
                  "patching_rect": [
                    40,
                    520,
                    38,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "o2",
                  "maxclass": "newobj",
                  "text": "out 2",
                  "numinlets": 1,
                  "numoutlets": 0,
                  "patching_rect": [
                    120,
                    520,
                    38,
                    22
                  ]
                }
              }
            ],
            "lines": [
              {
                "patchline": {
                  "source": [
                    "in1",
                    0
                  ],
                  "destination": [
                    "cb",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "cb",
                    0
                  ],
                  "destination": [
                    "o1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "cb",
                    1
                  ],
                  "destination": [
                    "o2",
                    0
                  ]
                }
              }
            ]
          }
        }
      },
      {
        "box": {
          "id": "plugout",
          "maxclass": "newobj",
          "text": "plugout~",
          "numinlets": 2,
          "numoutlets": 0,
          "patching_rect": [
            40,
            360,
            70,
            22
          ]
        }
      },
      {
        "box": {
          "id": "daz",
          "maxclass": "live.dial",
          "varname": "daz",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            40,
            40,
            46,
            48
          ],
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Azimuth",
              "parameter_shortname": "Azimuth",
              "parameter_type": 0,
              "parameter_mmin": -180,
              "parameter_mmax": 180,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1
            }
          },
          "parameter_enable": 1
        }
      },
      {
        "box": {
          "id": "del",
          "maxclass": "live.dial",
          "varname": "del",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            100,
            40,
            46,
            48
          ],
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Elevation",
              "parameter_shortname": "Elevation",
              "parameter_type": 0,
              "parameter_mmin": -90,
              "parameter_mmax": 90,
              "parameter_initial": [
                0.0
              ],
              "parameter_initial_enable": 1
            }
          },
          "parameter_enable": 1
        }
      },
      {
        "box": {
          "id": "ddist",
          "maxclass": "live.dial",
          "varname": "ddist",
          "numinlets": 1,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            160,
            40,
            46,
            48
          ],
          "saved_attribute_attributes": {
            "valueof": {
              "parameter_longname": "Distance",
              "parameter_shortname": "Distance",
              "parameter_type": 0,
              "parameter_mmin": 0.2,
              "parameter_mmax": 15,
              "parameter_initial": [
                7.6
              ],
              "parameter_initial_enable": 1
            }
          },
          "parameter_enable": 1
        }
      },
      {
        "box": {
          "id": "maz",
          "maxclass": "message",
          "text": "az $1",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            40,
            110,
            60,
            22
          ]
        }
      },
      {
        "box": {
          "id": "mel",
          "maxclass": "message",
          "text": "el $1",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            100,
            110,
            60,
            22
          ]
        }
      },
      {
        "box": {
          "id": "mdist",
          "maxclass": "message",
          "text": "dist $1",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            160,
            110,
            60,
            22
          ]
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "source": [
            "plugin",
            0
          ],
          "destination": [
            "sum",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "plugin",
            1
          ],
          "destination": [
            "sum",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "sum",
            0
          ],
          "destination": [
            "gen",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gen",
            0
          ],
          "destination": [
            "plugout",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "gen",
            1
          ],
          "destination": [
            "plugout",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "daz",
            0
          ],
          "destination": [
            "maz",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "maz",
            0
          ],
          "destination": [
            "gen",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "del",
            0
          ],
          "destination": [
            "mel",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mel",
            0
          ],
          "destination": [
            "gen",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "ddist",
            0
          ],
          "destination": [
            "mdist",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mdist",
            0
          ],
          "destination": [
            "gen",
            0
          ]
        }
      }
    ]
  }
}