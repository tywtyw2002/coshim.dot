
function key_ctrl_w()
    os.execute("sleep 0.1")
    root.fake_input("key_press", 37)
    root.fake_input("key_press", 25)
    root.fake_input("key_release", 25)
    root.fake_input("key_release", 37)
end
