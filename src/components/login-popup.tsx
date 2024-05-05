import { useState } from "react";
import UnknownPerson from "./unknown-person";
import { UndoOutlined } from "@ant-design/icons";
import { Modal, Button } from "antd";
import { createClient } from "@/utils/supabase/client";


export default function LoginPopup(): JSX.Element {

  const supabase = createClient();

  const [openPopup, setOpenPopup] = useState(false);

  function togglePopup(): void {
    setOpenPopup(!openPopup);
  }

  async function handleSignInWithGoogle() {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      }
    });

    console.warn(data);
  }


  return <>
    <div className=""
         onClick={ () => togglePopup()}>
      <UnknownPerson />
    </div>

    <Modal title="Login"
             footer={null}
             centered
             onCancel={ () => togglePopup() }
             open={openPopup} >
        <div className='grid grid-cols-3 md:grid-cols-4 gap-4 h-[320px] overflow-auto p-5'>
          {/* {
            avatarNumbers.map((eachNumber, index) => {
              return <div className='bg-third cursor-pointer p-1 w-fit h-fit rounded-full m-auto hover:opacity-50'
                          key={index}
                          onClick={() => changeAvatar(index) }>
                <Avatar src={`${AVATAR_URL}${eachNumber}`} className='w-12 h-12 ' />
              </div>
            })
          } */}
        </div>
        <div className='text-center mt-5'>
          <Button
            onClick={ () => handleSignInWithGoogle() }
            icon={<UndoOutlined />}>
            Login With Google
          </Button>
        </div>
      </Modal>
  </>
}