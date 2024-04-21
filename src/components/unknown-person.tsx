import { QuestionOutlined } from "@ant-design/icons";


export default function UnknownPerson( params: { size?: 'lg' | 'sm' } = { size: 'sm'}): JSX.Element {
  return <div className="w-full flex flex-col">
    <div className={`bg-third cursor-pointer ${params.size === 'lg' ? 'p-4' : 'p-2'}
                     rounded-full text-center m-auto hover:opacity-50 flex items-center justify-center`}>
      <QuestionOutlined className={ params.size === 'lg' ? 'text-3xl' : 'text-xl'}/>
    </div>
  </div>
}