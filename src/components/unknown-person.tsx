import { QuestionCircleOutlined } from "@ant-design/icons";


export default function UnknownPerson(): JSX.Element {
  return <div className="w-full flex flex-col">
    <div className={`bg-third cursor-pointer p-1 rounded-full text-center m-auto hover:opacity-50 w-10 h-10 flex items-center justify-center`}>
      <QuestionCircleOutlined className='text-xl'/>
    </div>
  </div>
}